# Use a Windows base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set working directory
WORKDIR C:\\Tensorflow_Vision

# Install Chocolatey for package management
RUN powershell -NoProfile -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Python3, Git, and essential tools using Chocolatey
RUN choco install -y python3 git visualstudio2019buildtools --include-optional --limit-output && \
    choco install -y cmake --install-arguments "'ADD_CMAKE_TO_PATH=System'"

# Update pip
RUN python -m pip install --upgrade pip

# Install libgl dependencies equivalent for Windows
RUN powershell -Command \
    Invoke-WebRequest -Uri https://aka.ms/vs/16/release/vs_buildtools.exe -OutFile vs_buildtools.exe; \
    .\vs_buildtools.exe --quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools

# Install required Python libraries
RUN python -m pip install numpy opencv-python scikit-learn pandas seaborn protobuf pycuda

# Clone YOLOv5 repository
RUN git clone https://github.com/ultralytics/yolov5.git C:\\Tensorflow_Vision\\yolov5

# Install YOLOv5 dependencies
RUN python -m pip install -r C:\\Tensorflow_Vision\\yolov5\\requirements.txt

# Download and install TensorRT (adjust the URL and path as needed)
RUN powershell -Command \
    Invoke-WebRequest -Uri https://developer.download.nvidia.com/compute/machine-learning/repos/windows/tensorrt/TensorRT-8.5.1.7.Windows10.x86_64.zip -OutFile TensorRT.zip; \
    Expand-Archive TensorRT.zip -DestinationPath C:\\TensorRT; \
    del TensorRT.zip

# Add TensorRT to PATH
RUN setx PATH "%PATH%;C:\\TensorRT\\bin"

# Install TensorRT Python bindings
RUN python -m pip install pycuda

# Expose default ports for Jupyter Notebook
EXPOSE 8888

# Set default command to launch Jupyter Notebook
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]

