FROM challisa/tessmix:latest

MAINTAINER Andy Challis <andrewchallis@hotmail.co.uk>
WORKDIR /
# Install any dependencies
RUN export OPENCV_VERSION="3.4.2" && \
    export PYTHON_VERSION="3.6" && \
    add-apt-repository ppa:jonathonf/python-3.6 && \
    apt-get update && \
    apt-get install -y \
    cmake \
    yasm \
    libswscale-dev \
    libtbb2 \
    libtbb-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libjasper-dev \
    libavformat-dev \
    libpq-dev \
  # Install ${PYTHON_VERSION}
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python3-pip && \
  # Make new python version easier to run by command python vs python3.6
    rm -f /usr/bin/python && \
    ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python && \
  # Update pip
    python -m pip install pip --upgrade && \
    python -m pip install wheel && \
    pip3 install numpy && \
  # Clear the cache
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \

  # Install OpenCV
  wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.tar.gz -O opencv.tar.gz \
    && tar -xvzf opencv.tar.gz \
    && wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.tar.gz -O opencv_contrib.tar.gz \
    && tar -xvzf opencv_contrib.tar.gz \
    && mkdir /opencv-${OPENCV_VERSION}/cmake_binary \
    && cd /opencv-${OPENCV_VERSION}/cmake_binary \
    && cmake \
      -DOPENCV_EXTRA_MODULES_PATH=/opencv_contrib-${OPENCV_VERSION}/modules \
      -DBUILD_TIFF=ON \
      -DBUILD_opencv_java=OFF \
      -DWITH_CUDA=OFF \
      -DENABLE_AVX=ON \
      -DWITH_OPENGL=ON \
      -DWITH_OPENCL=ON \
      -DWITH_IPP=ON \
      -DWITH_TBB=ON \
      -DWITH_EIGEN=ON \
      -DWITH_V4L=ON \
      -DBUILD_TESTS=OFF \
      -DBUILD_PERF_TESTS=OFF \
      -DCMAKE_BUILD_TYPE=RELEASE \
      -DCMAKE_INSTALL_PREFIX=$(python -c "import sys; print(sys.prefix)") \
      -DPYTHON_EXECUTABLE=$(which python) \
      -DPYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
      -DPYTHON_PACKAGES_PATH=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
    && make -j5 \
    && cd / \
    && rm /opencv_contrib.tar.gz \
    && rm /opencv.tar.gz \
    && rm -r /opencv-${OPENCV_VERSION} \
    && rm -r /opencv_contrib-${OPENCV_VERSION} \
  # Install OpenCV for Python
    && pip3 install opencv-contrib-python-headless
