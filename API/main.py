from fastapi import FastAPI, File, UploadFile, Header
from fastapi.responses import JSONResponse, FileResponse
import subprocess
import tempfile
import random
import string
import cloudinary
import cloudinary.uploader
import cloudinary.api 


app = FastAPI()

# Configure Cloudinary credentials
cloudinary.config(
    cloud_name="dxxdandwe",
    api_key="349349869632963",
    api_secret="KeQtzpSk9MbzzAhOb1nd6WTkTiY"
)

def determine_media_type(filename: str) -> str:
    """
    Determine the media type based on the file extension.
    """
    ext = filename.rsplit('.', 1)[-1].lower()
    switcher = {
        "jpg": "image/jpeg",
        "jpeg": "image/jpeg",
        "png": "image/png",
        "gif": "image/gif",
        "bmp": "image/bmp",
        "tiff": "image/tiff",
        "webp": "image/webp"
    }
    return switcher.get(ext, "image/jpeg")
@app.post("/process_image/")
async def process_image(file: UploadFile = File(...)):
    """
    Receive an image, process it with the 'invisible-watermark' command,
    and send back the processed image URL along with the random string as a watermark.
    """
    media_type = determine_media_type(file.filename)

    # Generate a random string containing lowercase alphabets
    random_string = ''.join(random.choice(string.ascii_lowercase) for _ in range(32))  # Adjust the length as needed

    # Create temporary files in the standard temporary directory
    with tempfile.NamedTemporaryFile(delete=False, suffix=".jpg") as input_tmp, \
         tempfile.NamedTemporaryFile(delete=False, suffix=".png") as output_tmp:

        # Write the uploaded file content to the temporary input file
        input_tmp.write(await file.read())
        input_tmp.flush()

        # Run the watermark embedding command
        subprocess.run([
            'invisible-watermark', '-v', '-a', 'encode', '-t', 'bytes',
            '-m', 'dwtDct', '-w', random_string, '-o', output_tmp.name,
            input_tmp.name
        ], check=True)

        # Upload processed image to Cloudinary
        cloudinary_response = cloudinary.uploader.upload(output_tmp.name)
        print(cloudinary_response)
        # Return Cloudinary URL and other details
        return {
            "media_type": media_type,
            "watermark": random_string,
            "image_id": cloudinary_response['public_id']
        }

@app.post("/decode_image/")
async def decode_image(file: UploadFile = File(...), watermark: str = Header(None)):
    """
    Receive an image, process it with the 'invisible-watermark' command to decode the watermark,
    and if the watermark is valid, upload the image to Cloudinary and return the URL.
    """
    media_type = determine_media_type(file.filename)
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as input_tmp:
        # Write the uploaded file content to the temporary input file
        input_tmp.write(await file.read())
        input_tmp.flush()

        # Run the watermark decoding command and capture the output
        result = subprocess.run([
            'invisible-watermark', '-v', '-a', 'decode', '-t', 'bytes', 
            '-m', 'dwtDct', '-l', '256', input_tmp.name
        ], capture_output=True, text=True)

        if result.returncode != 0:
            # Log error for debugging
            print("Error:", result.stderr)
            return JSONResponse(content={"error": "Command execution failed"}, status_code=500)

        # Split the output by line and extract the watermark
        output_lines = result.stdout.strip().split('\n')
        print(watermark)
        print(output_lines)
        if len(output_lines) >= 2:
            decoded_watermark = output_lines[1].strip()  # Extracting the second line which contains the watermark
            
            # Verify the decoded watermark with the provided watermark in the header
            diff_count = sum(1 for a, b in zip(watermark, decoded_watermark) if a != b)
            print(diff_count)
            print(len(watermark)==len(decoded_watermark))

            if diff_count <= 3 and len(watermark)==len(decoded_watermark):
                # If at most 3 characters are different, return the response
                cloudinary_response = cloudinary.uploader.upload(input_tmp.name)

                # Return Cloudinary URL and other details
                return {
                    "media_type": media_type,
                    "watermark": watermark,
                    "image_id": cloudinary_response['public_id']  # Return the secure URL from Cloudinary
                }

        # If the watermark is not valid or not found, return an error response
        return JSONResponse(content={"error": "Watermark not found or not valid"}, status_code=400)

@app.post("/detect_image/")
async def detect_image(
    file: UploadFile = File(...),
    watermark: str = Header(None)
):
    """
    Receive an image, decode the watermark, and return the watermark as a response.
    """
    print(watermark)

    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as input_tmp:
        # Write the uploaded file content to the temporary input file
        input_tmp.write(await file.read())
        input_tmp.flush()

        # Run the watermark decoding command and capture the output
        result = subprocess.run([
            'invisible-watermark', '-v', '-a', 'decode', '-t', 'bytes', 
            '-m', 'dwtDct', '-l', '256', input_tmp.name
        ], capture_output=True, text=True)

        if result.returncode != 0:
            # Log error for debugging
            print("Error:", result.stderr)
            return JSONResponse(content={"error": "Command execution failed"}, status_code=500)
        # Split the output by line and extract the watermark
        output_lines = result.stdout.strip().split('\n')
        print(watermark)
        print(output_lines)
        if len(output_lines) >= 2:
            decoded_watermark = output_lines[1].strip()  # Extracting the second line which contains the watermark
            # Verify the decoded watermark with the provided watermark in the header
            # Verify the decoded watermark with the provided watermark in the header
            diff_count = sum(1 for a, b in zip(watermark, decoded_watermark) if a != b)
            print(diff_count)
            print(len(watermark)==len(decoded_watermark))
            if diff_count <= 3 and len(watermark)==len(decoded_watermark):
                # If at most 3 characters are different, return the response
                return JSONResponse(content={"watermark": "Valid encoded watermark"})
        
        # If the watermark is not valid or not found, return an error response
        return JSONResponse(content={"error": "Watermark not found or deepfake is applied"}, status_code=400)


@app.post("/delete_image/{image_id}")
async def delete_image(image_id: str):
    # Delete the image from Cloudinary using the provided public_id
    try:
        deletion_response = cloudinary.api.delete_resources([image_id])
        return JSONResponse(content=deletion_response, status_code=200)
    except Exception as e:
        print(f"Error deleting image: {e}")
        return JSONResponse(content={"error": "Image deletion failed"}, status_code=500)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)



# @app.post("/process_image/")
# async def process_image(file: UploadFile = File(...)):
#     """
#     Receive an image, process it with the 'invisible-watermark' command, 
#     and send back the processed image.
#     """
#     media_type = determine_media_type(file.filename)
#     random_string=""
#     with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as input_tmp, \
#          tempfile.NamedTemporaryFile(suffix=".png", delete=False) as output_tmp:

#         # Write the uploaded file content to the temporary input file
#         input_tmp.write(await file.read())
#         input_tmp.flush()

#         # Run the watermark embedding command
#         subprocess.run([
#             'invisible-watermark', '-v', '-a', 'encode', '-t', 'bytes', 
#             '-m', 'dwtDct', '-w', random_string, '-o', output_tmp.name, 
#             input_tmp.name
#         ], check=True)

#         # Return the processed image
#         output_tmp.seek(0)
#         return FileResponse(output_tmp.name, media_type=media_type)

# @app.post("/decode_image/")
# async def decode_image(file: UploadFile = File(...)):
#     """
#     Receive an image, process it with the 'invisible-watermark' command to decode the watermark, 
#     and send back the processed image.
#     """
#     media_type = determine_media_type(file.filename)

#     with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as input_tmp:

#         # Write the uploaded file content to the temporary input file
#         input_tmp.write(await file.read())
#         input_tmp.flush()

#         # Run the watermark decoding command
#         subprocess.run([
#             'invisible-watermark', '-v', '-a', 'decode', '-t', 'bytes', 
#             '-m', 'dwtDct', '-l', '40', input_tmp.name
#         ], check=True)
#         # Return the processed image
#         input_tmp.seek(0)
#         return FileResponse(input_tmp.name, media_type=media_type)