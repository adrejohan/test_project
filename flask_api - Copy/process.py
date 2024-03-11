import os
import numpy as np
from pdf2image import convert_from_path

popler_path = r".\poppler\Library\bin"

def process_pdf(pdf):
    filename = os.path.splitext(os.path.basename(pdf))[0]
    images = convert_from_path(pdf, poppler_path=popler_path)
    for j in range(len(images)):
        width, height = images[j].size
        image_crop = images[j].crop((0,0,3000,height))
        image_crop_1 = np.array(image_crop.crop((0,0,1530,height//2+30)))[:,:,:3]
        image_crop_2 = np.array(image_crop.crop((1470,0,3000,height//2+30)))[:,:,:3]
        image_crop_3 = np.array(image_crop.crop((0,height//2-30,1530,height)))[:,:,:3]
        image_crop_4 = np.array(image_crop.crop((1470,height//2-30,3000,height)))[:,:,:3]
        image_crop_list = [width, height, np.array(image_crop)[:,:,:3], image_crop_1, image_crop_2, image_crop_3, image_crop_4]
    return image_crop_list