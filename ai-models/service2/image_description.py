from transformers import AutoProcessor, Blip2ForConditionalGeneration
import torch

class ImageDescriptionModel:
    
    def __init__(self):
        # # Configuración del modelo
        # model_name = "Salesforce/blip2-opt-6.7b"  # Modelo más ligero
        # # self.device = "cpu"
        # self.device = "cuda" if torch.cuda.is_available() else "cpu"

        # self.processor = AutoProcessor.from_pretrained(model_name)
        # self.model = Blip2ForConditionalGeneration.from_pretrained(model_name, torch_dtype=torch.float32)
        # self.model.to(self.device)


        model_name = "Salesforce/blip2-opt-2.7b"
        self.device = "cuda" if torch.cuda.is_available() else "cpu"

        # Asignar a atributos de la clase
        self.processor = AutoProcessor.from_pretrained(model_name)
        self.model = Blip2ForConditionalGeneration.from_pretrained(model_name, torch_dtype=torch.float16)
        self.model.to(self.device)

    def describe(self, image):
        # Prompt personalizado
        
        # Procesar la imagen con el prompt
        inputs = self.processor(image, return_tensors="pt").to(self.device, torch.float16)
        generated_ids = self.model.generate(**inputs, max_new_tokens=100)  # Aumenta max_new_tokens para descripciones más largas
        generated_text = self.processor.batch_decode(generated_ids, skip_special_tokens=True)[0].strip()
        return generated_text
