import random
from flask import Flask, request, Response, send_from_directory, url_for, render_template
from flask_cors import CORS
import json

from pdf2image import convert_from_bytes
from recognizer import Recognizer
from detector import detector
import numpy as np
import base64
import cv2
import os
import boto3
import datetime
import concurrent.futures

app = Flask(__name__)
cors = CORS(app)
recognizer=Recognizer("model/yolov8m_custom.pt")
Detector = detector()
PATH = "./upload/"
ACCESS_KEY = "AKIA4OCGXRV3M5RPEOGS"
SECRET_KEY = "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"
BUCKET_NAME = "testingstorageyolo"
POPLER_PATH = r".\poppler\Library\bin"
s3_storage = boto3.client("s3", aws_access_key_id = ACCESS_KEY, aws_secret_access_key = SECRET_KEY)
app.config["PUBLIC_FOLDER"]=PATH

label_color = {}

def default(o):
    if isinstance(o, np.float32):
        return float(o)
    raise TypeError


@app.route('/pdfs', methods=['POST'])
def process_image():
    if request.method=="POST":
        images = []
        objects_to_upload = {}
        data=request.json.get("pdfs")
        start0 = datetime.datetime.now()
        for image_b64 in data:
            start = datetime.datetime.now() 
            pdf_base64 = base64.b64decode(image_b64["image"])
            pages = convert_from_bytes(pdf_base64, poppler_path=POPLER_PATH)
            
            
            for j in range(len(pages)):
                annot_list = []
                image_url_list = []
                
                _, height = pages[j].size
                image_crop = pages[j].crop((0,0,3000,height))
                image_crop_1 = np.array(image_crop.crop((0,0,1530,height//2+30)))[:,:,:3]
                image_crop_2 = np.array(image_crop.crop((1470,0,3000,height//2+30)))[:,:,:3]
                image_crop_3 = np.array(image_crop.crop((0,height//2-30,1530,height)))[:,:,:3]
                image_crop_4 = np.array(image_crop.crop((1470,height//2-30,3000,height)))[:,:,:3]
                image_crop_list = [image_crop_1, image_crop_2, image_crop_3, image_crop_4]
                
                for i in range (len(image_crop_list)):
                    recognizer.recognize(image_crop_list[i], annot_list, height, counter=i)
                
                image_np = np.array(image_crop)[:,:,:3]
                annot_count_list = label_count(annot_list)
                generate_color(annot_count_list, label_color)
                processing_image(image_url_list, image_np, image_b64, annot_list, label_color, objects_to_upload)
                
                if len(annot_count_list)>1:
                    for label in annot_count_list:
                        processing_image(image_url_list, image_np, image_b64, annot_list, label_color, objects_to_upload, label)
                        
                
                image_data = {
                    "image_name":image_b64["name"],
                    "image_url":image_url_list,
                    "annotations_count":annot_count_list,
                }
                images.append(image_data)
                print("run image:", (datetime.datetime.now()-start).seconds)
                
                
        upload_objects_concurrently(BUCKET_NAME, objects_to_upload)
        json_data = {"data":images} 
        response = json.dumps(json_data).encode('utf8')
        
        print("total run:", (datetime.datetime.now()-start0).seconds)
        
        return Response(response=response, status=200, mimetype="application/json")
    
@app.route('/')
def render_page():
    return render_template('index.html')


@app.route('/web/')
def render_page_web():
    return render_template('index.html')

@app.route('/web/<path:name>')
def return_flutter_doc(name):

    datalist = str(name).split('/')
    DIR_NAME = 'templates'

    if len(datalist) > 1:
        for i in range(0, len(datalist) - 1):
            DIR_NAME += '/' + datalist[i]

    return send_from_directory(DIR_NAME, datalist[-1])

def generate_color(label_group, label_color):
    for label in label_group:
        if label not in label_color:
            colors = tuple(random.randint(0, 255) for _ in range(3))
            label_color[label] = colors
    
def label_count(data):
    label_counts = {}

    for item in data:
        label = item['label']
        if label in label_counts:
            label_counts[label] += 1
        else:
            label_counts[label] = 1

    return label_counts
    
def processing_image(image_url_list, image_np, image_b64, annotations, label_color, objects_to_upload, label_flag=None):
    
    image_processed = Detector.draw_annotations(image_np, annotations, label_color, label_flag)
    
    image_processed_bgr = cv2.cvtColor(image_processed, cv2.COLOR_RGB2BGR)
    _, image_processed_bin = cv2.imencode(".jpg", image_processed_bgr)
         
    if label_flag == None:
        filename = os.path.splitext(image_b64["name"])[0]+".jpg"
    else:
        filename = os.path.splitext(image_b64["name"])[0]+"_"+label_flag+".jpg"
    objects_to_upload[filename]=image_processed_bin.tobytes()
    # s3_storage.put_object(Bucket = BUCKET_NAME, Key = filename, Body = image_processed_bin.tobytes())
    
    image_url_list.append("https://testingstorageyolo.s3.ap-northeast-1.amazonaws.com/"+filename)
    
def upload_to_s3(bucket_name, key, data):
    s3_storage.put_object(Bucket=bucket_name, Key=key, Body=data)

def upload_objects_concurrently(bucket_name, objects):
    with concurrent.futures.ThreadPoolExecutor() as executor:
        futures = [executor.submit(upload_to_s3, bucket_name, key, data) for key, data in objects.items()]
        # Wait for all futures to complete
        concurrent.futures.wait(futures)
    
    

if __name__ == '__main__':
    app.run(host='0.0.0.0', ssl_context="adhoc", port=443)
    