import random
import cv2
import numpy as np
import io
import requests
import copy

class detector:
    def __init__(self) -> None:
        pass
    def frame_to_png_buffer(self, frame):
        is_success, buffer = cv2.imencode(".png", frame)
        if not is_success:
            raise Exception("Could not encode image")

        io_buf = io.BytesIO(buffer)
        return io_buf

    def get_annotated_image(self):
        frame = self.get_frame()
        io_buf = self.frame_to_png_buffer(frame)
        response = requests.post(self.server_url, files={"image": io_buf})

        if response.status_code == 200:
            # print("Image successfully sent to server")
            pass
        else:
            print("Failed to send image to server")

        annotations = response.json()
        annotated_frame = self.draw_annotations(frame, annotations)
        return frame, annotated_frame, annotations
    
    def draw_rect_and_text(self, img, xmin, ymin, xmax, ymax, label, conf, label_color):
        cv2.rectangle(img, pt1=(xmin, ymin), pt2=(xmax, ymax), color=label_color[label], thickness=2)
            # Add the label
        y = ymin - 15 if ymin - 15 > 15 else ymin + 15
        cv2.putText(img, label, (xmin, y), cv2.FONT_HERSHEY_SIMPLEX, 0.5, label_color[label], 2)

            # add confidence
        cv2.putText(img, str(conf)+"%", (xmin, y+15),cv2.FONT_HERSHEY_SIMPLEX, 0.5, label_color[label], 2)
        
        

    def draw_annotations(self, original_img, annotations, label_color, label_flag=None):
        img = copy.deepcopy(original_img)
        for annotation in annotations:
            xmin = int(annotation["xmin"])
            ymin = int(annotation["ymin"])
            xmax = int(annotation["xmax"])
            ymax = int(annotation["ymax"])
            label = annotation["label"]
            conf = round(annotation["conf"], 4)*100

            if label_flag == None:
                self.draw_rect_and_text(img, xmin, ymin, xmax, ymax, label, conf, label_color)
            
            else :
                if label == label_flag:
                    self.draw_rect_and_text(img, xmin, ymin, xmax, ymax, label, conf, label_color)
            
        return np.array(img)

        
    
    