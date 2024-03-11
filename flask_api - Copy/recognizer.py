from ultralytics import YOLO

class Recognizer:
    def __init__(self,model_path):
        self.model = YOLO(model_path)
        self.names = self.model.names

    def recognize(self, img, annot_list, height, counter, conf=0.25):
        
        def annot_listing(annot_list, label, conf, xmin, ymin, xmax, ymax, xadd, yadd):
            d={
                "label":label,
                "conf":float(conf),
                "xmin":xmin+xadd,
                "ymin":ymin+yadd,
                "xmax":xmax+xadd,
                "ymax":ymax+yadd
            }
            annot_list.append(d)
        
        preds =self. model.predict(img,conf=conf, classes=[0,1,2])
        for box in preds[0].boxes:
            label=self.names[box.cls.cpu().numpy()[0]]
            conf=box.conf.cpu().numpy()[0]
            xmin, ymin, xmax, ymax=box.xyxy.cpu().numpy()[0]
            xmin, ymin, xmax, ymax=int(xmin), int(ymin), int(xmax), int(ymax)
            
            
            
            if counter == 0:
                if xmax <= 1500 and ymax <= height//2:
                    annot_listing(annot_list, label, conf, xmin, ymin, xmax, ymax, 0, 0)
                elif (xmin <= 1500 and xmax > 1500) and ymax <= height//2:
                    if (1500-xmin) > (xmax-1500):
                        annot_listing(annot_list, label, conf, xmin, ymin, xmax, ymax, 0, 0)
                elif xmax <= 1500 and (ymin <= height//2 and ymax > height//2):
                    if (height//2-ymin) > (ymax-height//2):
                        annot_listing(annot_list, label, conf, xmin, ymin, xmax, ymax, 0, 0)
            elif counter == 1:
                if xmin >= 30 and ymax <= height//2:
                    annot_listing(annot_list, label, conf, xmin, ymin, xmax, ymax, 1470, 0)
                elif (xmin < 30 and xmax >= 30) and ymax <= height//2:
                    if (30-xmin) < (xmax-30):
                        annot_listing(annot_list, label, conf, xmin, ymin, xmax, ymax, 1470, 0)
                elif xmin >= 30 and (ymin <= height//2 and ymax > height//2):
                    if (height//2-ymin) > (ymax-height//2):
                        annot_listing(annot_list, label, conf, xmin, ymin, xmax, ymax, 1470, 0)
            elif counter == 2:
                if xmax <= 1500 and ymin >= 30:
                    annot_listing(annot_list, label, conf, xmin, ymin, xmax, ymax, 0, height//2-30)
                elif (xmin <= 1500 and xmax > 1500) and ymin >= 30:
                    if (1500-xmin) > (xmax-1500):
                        annot_listing(annot_list, label, conf, xmin, ymin, xmax, ymax, 0, height//2-30)
                elif xmax <= 1500 and (ymin <= 30 and ymax > 30):
                    if (30-ymin) < (ymax-30):
                        annot_listing(annot_list, label, conf, xmin, ymin, xmax, ymax, 0, height//2-30)
            else:
                if xmin >= 30 and ymin >= 30:
                    annot_listing(annot_list, label, conf, xmin, ymin, xmax, ymax, 1470, height//2-30)
                elif (xmin < 30 and xmax >= 30) and ymin >= 30:
                    if (30-xmin) < (xmax-30):
                        annot_listing(annot_list, label, conf, xmin, ymin, xmax, ymax, 1470, height//2-30)
                elif xmax <= 1500 and (ymin <= 30 and ymax > 30):
                    if (30-ymin) < (ymax-30):
                        annot_listing(annot_list, label, conf, xmin, ymin, xmax, ymax, 1470, height//2-30)

           
        return annot_list