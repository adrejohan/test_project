import itertools
import random
from PIL import Image
import io
from flask import Flask, request, Response, send_from_directory, url_for, render_template
from flask_cors import CORS
import json
from recognizer import Recognizer
from detector import detector
from process import process_pdf
import numpy as np
import base64
import cv2
import os
import boto3

app = Flask(__name__)
cors = CORS(app)
recognizer=Recognizer("model/yolov8m_custom.pt")
Detector = detector()
PATH = "./upload/"
ACCESS_KEY = "AKIA4OCGXRV3M5RPEOGS"
SECRET_KEY = "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"
BUCKET_NAME = "testingstorageyolo"
s3_storage = boto3.client("s3", aws_access_key_id = ACCESS_KEY, aws_secret_access_key = SECRET_KEY)
app.config["PUBLIC_FOLDER"]=PATH

def default(o):
    if isinstance(o, np.float32):
        return float(o)
    raise TypeError


# @app.route('/images', methods=['POST'])
# def process_image():
#     if request.method=="POST":
#         images = []
#         label_color = {}
#         image_url_list = []
#         data=request.json.get("images")
#         for image_b64 in data:
            
#             image_base64 = base64.b64decode(image_b64["image"])
#             image_bin = io.BytesIO(image_base64)
            
#             image = Image.open(image_bin)
#             image_np = np.array(image)[:,:,:3]
            
#             annotations = recognizer.recognize(image_np)
#             label_group = label_count(annotations)
#             generate_color(label_group, label_color)
            
#             processing_image(image_url_list, image_np, image_b64, annotations, label_color)
            
#             if len(label_group)>1:
#                 for label in label_group:
#                     processing_image(image_url_list, image_np, image_b64, annotations, label_color, label)
            
#             print(image_url_list[0])
            
#             image_data = {
#                 "image_name":image_b64["name"],
#                 "image_url":image_url_list[0],
#                 "annotations":label_group
#             }
#             images.append(image_data)
        
#         json_data = {"data":images} 
#         response = json.dumps(json_data).encode('utf8')
            
#         return Response(response=response, status=200, mimetype="application/json")
    
# @app.route('/')
# def render_page():
#     return render_template('index.html')


# @app.route('/web/')
# def render_page_web():
#     return render_template('index.html')

# @app.route('/web/<path:name>')
# def return_flutter_doc(name):

#     datalist = str(name).split('/')
#     DIR_NAME = 'templates'

#     if len(datalist) > 1:
#         for i in range(0, len(datalist) - 1):
#             DIR_NAME += '/' + datalist[i]

#     return send_from_directory(DIR_NAME, datalist[-1])


    
def label_count(data):
    label_counts = {}

    for item in data:
        label = item['label']
        if label in label_counts:
            label_counts[label] += 1
        else:
            label_counts[label] = 1

    return label_counts

def generate_color(label_group, label_color):
    for label in label_group:
        if label not in label_color:
            colors = tuple(random.randint(0, 255) for _ in range(3))
            label_color[label] = colors
    
def processing_image(image_url_list, image_np, image_b64, annotations, label_color, label_flag=None):
    image_processed = Detector.draw_annotations(image_np, annotations, label_color, label_flag)
    image_processed_bgr = cv2.cvtColor(image_processed, cv2.COLOR_RGB2BGR)
    _, image_processed_bin = cv2.imencode(".jpg", image_processed_bgr)
            
    if label_flag == None:
        filename = os.path.splitext(image_b64["name"])[0]+".jpg"
    else:
        filename = os.path.splitext(image_b64["name"])[0]+"_"+label_flag+".jpg"
    s3_storage.put_object(Bucket = BUCKET_NAME, Key = filename, Body = image_processed_bin.tobytes())
    
    image_url_list.append("https://testingstorageyolo.s3.ap-northeast-1.amazonaws.com/"+filename)

if __name__ == '__main__':
    label_color = {'human_sensor': (255, 0, 0), 'r_circuit_1': (0, 255, 0), 'r_circuit_2': (0, 0, 255)}
    annot_dict = {"0": [], "1": [], "2": [], "3": []}
    image_processed_list = []
    annot_list = []
    split_pdf = process_pdf("5.pdf")
    width, height = split_pdf[0], split_pdf[1]
    split_image_list = split_pdf[3:]
    
    for i in range (len(split_image_list)):
        recognizer.recognize(split_image_list[i], annot_dict, height, counter=i)
        image_processed = Detector.draw_annotations(split_image_list[i],annot_dict[str(i)],label_color)
        image_processed_bgr = cv2.cvtColor(image_processed, cv2.COLOR_RGB2BGRA)
        image_processed_list.append(image_processed_bgr)
        print(i, label_count(annot_dict[str(i)]))
        
    annot_dict_copy = annot_dict.copy()
        
    image_processed_unite = Detector.draw_annotations(split_pdf[2],annot_dict[str(i)],label_color)
    for i in annot_dict_copy["1"]:
        i["xmin"] += 1470
        i["xmax"] += 1470
    
    for i in annot_dict_copy["2"]:
        i["ymin"] += height//2-30
        i["ymax"] += height//2-30
        
    for i in annot_dict_copy["3"]:
        i["xmin"] += 1470
        i["xmax"] += 1470
        i["ymin"] += height//2-30
        i["ymax"] += height//2-30
        
    for i in range(4):
        annot_list += annot_dict_copy[str(i)]
        
    image_processed = Detector.draw_annotations(split_pdf[2],annot_list,label_color)
        
    cv2.namedWindow("Resized_Window_1", cv2.WINDOW_NORMAL) 
    cv2.resizeWindow("Resized_Window_1", width//4, height//4) 
    cv2.imshow("Resized_Window_1", image_processed)
    
    # cv2.namedWindow("Resized_Window_2", cv2.WINDOW_NORMAL) 
    # cv2.resizeWindow("Resized_Window_2", width//4, height//4) 
    # cv2.imshow("Resized_Window_2", image_processed_list[1])
    
    # cv2.namedWindow("Resized_Window_3", cv2.WINDOW_NORMAL) 
    # cv2.resizeWindow("Resized_Window_3", width//4, height//4) 
    # cv2.imshow("Resized_Window_3", image_processed_list[2])
    
    # cv2.namedWindow("Resized_Window_4", cv2.WINDOW_NORMAL) 
    # cv2.resizeWindow("Resized_Window_4", width//4, height//4) 
    # cv2.imshow("Resized_Window_4", image_processed_list[3])
    
    cv2.waitKey(0)
    cv2.destroyAllWindows() 
    