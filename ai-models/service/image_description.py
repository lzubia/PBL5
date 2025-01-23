from transformers import BlipProcessor, BlipForConditionalGeneration
import torch

class ImageDescriptionModel:
    
    def __init__(self):
        model_name = "Salesforce/blip-image-captioning-base"
        self.device = "cuda" if torch.cuda.is_available() else "cpu"

        # Asignar a atributos de la clase
        self.processor = BlipProcessor.from_pretrained(model_name)
        self.model = BlipForConditionalGeneration.from_pretrained(model_name, torch_dtype=torch.float16)
        self.model.to(self.device)

    def describe(self, image):
        inputs = self.processor(image, return_tensors="pt").to(self.device, torch.float16)
        out = self.model.generate(**inputs)
        generated_text = self.processor.decode(out[0], skip_special_tokens=True)

        return generated_text