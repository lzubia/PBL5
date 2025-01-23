import pytesseract
from PIL import Image
import cv2
from symspellpy.symspellpy import SymSpell, Verbosity
from io import BytesIO
import numpy as np

class OCR_Model:
    def preprocess_image(self, image):
        """
        Preprocess the image, converting it to grayscale, applying binary thresholding and gaussian blur.
        """
        # Convert PIL image to numpy array for OpenCV processing
        image_np = np.array(image)
        # Convert to grayscale
        gray = cv2.cvtColor(image_np, cv2.COLOR_RGB2GRAY)
        # Apply binary thresholding (Otsu's method)
        _, binary_thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
        # Optional: Apply Gaussian blur to reduce noise
        blurred = cv2.GaussianBlur(binary_thresh, (3, 3), 0)
        return blurred

    def correct_text_with_symspell(self, text):
        """
        Corrects the text spellig using SymSpell and the Frequency Dictionary (english 82 765).
        """
        # Initialize SymSpell
        sym_spell = SymSpell(max_dictionary_edit_distance=2, prefix_length=7)
        
        # Load a dictionary
        dictionary_path = "./frequency_dictionary_en_82_765.txt"
        sym_spell.load_dictionary(dictionary_path, term_index=0, count_index=1)
        
        # Correct the OCR output
        corrected_text = []
        for word in text.split():
            # Find the closest word suggestions
            suggestions = sym_spell.lookup(word, Verbosity.CLOSEST, max_edit_distance=2)
            # Use the most probable suggestion if available
            corrected_text.append(suggestions[0].term if suggestions else word)
        
        return " ".join(corrected_text)

    def execute_ocr(self, file):
        """
        Executes the ocr process: Preprocessing image, detecting text and correcting the spelling of the output.
        """
        try:
            # Load the image using PIL
            image = Image.open(BytesIO(file.file.read()))
            
            # Preprocess the image
            preprocessed_image = self.preprocess_image(image) 
            
            # Convert preprocessed image back to PIL format
            pil_image = Image.fromarray(preprocessed_image)
            
            # Set custom Tesseract configuration
            custom_config = r'--oem 3 --psm 6'
            
            # Perform OCR
            ocr_text = pytesseract.image_to_string(pil_image, config=custom_config)
            
            # Correct text using SymSpell
            corrected_text = self.correct_text_with_symspell(ocr_text)
            
            return corrected_text
        except Exception as e:
            raise Exception(f"Error during OCR processing: {str(e)}")