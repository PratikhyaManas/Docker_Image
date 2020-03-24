# Importing
FROM balenalib/raspberry-pi-debian:latest
# Maintainer Name 
MAINTAINER Pratikhya Manas <manasxxxxxx@gmail.com>
# Add Google Coral sources lists
RUN echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | sudo tee /etc/apt/sources.list.d/coral-edgetpu.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - \
 && curl -O https://bootstrap.pypa.io/get-pip.py 
 
# Install the TPU packages we will need 
RUN install_packages libedgetpu1-std \
            libedgetpu-dev \
            python3-edgetpu \
            edgetpu-examples \
            python3-pip
# Creating Virtual Environment
RUN rm -rf ~/.cache/pip 
RUN pip3 install virtualenv 
RUN pip3 install virtualenvwrapper
RUN echo "# virtualenv and virtualenvwrapper" >> $HOME/.bashrc && \
    echo "export WORKON_HOME=$HOME/.virtualenvs" >> $HOME/.bashrc && \
 echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> $HOME/.bashrc && \
    echo "source \"/usr/local/bin/virtualenvwrapper.sh\"" >> $HOME/.bashrc && \
 dpkg -L python3-edgetpu 
 
# Creating sym-link 
WORKDIR ~/.virtualenvs/coral/lib/python3.7/site-packages \
    && ln -s /usr/lib/python3/dist-packages/edgetpu/ edgetpu
WORKDIR ~
# Intializing the Environment Variables
ENV WORKON_HOME ~/.virtualenvs
ENV VIRTUALENVWRAPPER_PYTHON /usr/bin/python3
# Installing the necessary packages
RUN /bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh; mkvirtualenv coral_test -p python3" \
    && cd $HOME \
 && pip3 install "picamera[array]" \
    && pip3 install numpy \
    && pip3 install opencv-contrib-python==4.1.0.25 \
    && pip3 install imutils \
    && pip3 install scikit-image \
    && pip3 install pillow \ 
 && apt-get install edgetpu-examples \
 && chmod a+w /usr/share/edgetpu/examples 
 
# Working on the Object Detection Problem 
WORKDIR /usr/share/edgetpu/examples \
 && export DISPLAY=":0" \
 && python classify_image.py --mode models/mobilenet_v2_1.0_224_inat_bird_quant_edgetpu.tflite --label models/inat_bird_labels.txt --image images/parrot.jpg