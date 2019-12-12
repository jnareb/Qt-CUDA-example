#-------------------------------------------------
#
# Project created by QtCreator 2014-03-17T09:30:15
#
#-------------------------------------------------

CONFIG += console

TARGET = Qt-CUDA-example

# Define output directories
DESTDIR = ../bin
CUDA_OBJECTS_DIR = OBJECTS_DIR/../cuda

# This makes the .cu files appear in your project
# OTHER_FILES += \
#     vectorAdd.cu
CUDA_SOURCES += \
    vectorAdd.cu

#-------------------------------------------------

# MSVCRT link option (static or dynamic, it must be the same with your Qt SDK link option)
MSVCRT_LINK_FLAG_DEBUG   = "/MDd"
MSVCRT_LINK_FLAG_RELEASE = "/MD"

# CUDA settings
CUDA_DIR = $$(CUDA_PATH)            # Path to cuda toolkit install
SYSTEM_NAME = x64                   # Depending on your system either 'Win32', 'x64', or 'Win64'
SYSTEM_TYPE = 64                    # '32' or '64', depending on your system
CUDA_ARCH = sm_50                   # Type of CUDA architecture
NVCC_OPTIONS = --use_fast_math

# include paths
INCLUDEPATH += $$CUDA_DIR/include \
               $$CUDA_DIR/common/inc \
               $$CUDA_DIR/../shared/inc

# library directories
win32 {
    QMAKE_LIBDIR += $$CUDA_DIR/lib/$$SYSTEM_NAME \
                    $$CUDA_DIR/common/lib/$$SYSTEM_NAME \
                    $$CUDA_DIR/../shared/lib/$$SYSTEM_NAME
}
linux {
    QMAKE_LIBDIR += $$CUDA_DIR/lib$$SYSTEM_TYPE
}

# The following makes sure all path names (which often include spaces) are put between quotation marks
CUDA_INC = $$join(INCLUDEPATH, '" -I"','-I"','"')
CUDA_LIB = $$join(QMAKE_LIBDIR,'" -L"','-L"','"')

# Add the necessary libraries
win32:CUDA_LIB_NAMES = cudart_static kernel32 user32 gdi32 winspool comdlg32 \
                 advapi32 shell32 ole32 oleaut32 uuid odbc32 odbccp32 \
                 #freeglut glew32
linux:CUDA_LIB_NAMES = cuda cudart

for(lib, CUDA_LIB_NAMES) {
    CUDA_LIBS += -l$$lib
}
LIBS += $$CUDA_LIBS
linux:LIBS += -lcuda -lcudart

# Configuration of the Cuda compiler
NVCC=nvcc
win32 {
    NVCC = $$CUDA_DIR/bin/nvcc.exe
    NVCCFLAGS = --compile -cudart static -DWIN32 -D_MBCS
    CONFIG(debug, debug|release) {
        NVCC_COMPILER_FLAGS = \
            -Xcompiler "/wd4819,/EHsc,/W3,/nologo,/Od,/Zi,/RTC1" \
            -Xcompiler $$MSVCRT_LINK_FLAG_DEBUG
    }
    else {
        NVCC_COMPILER_FLAGS = \
            -Xcompiler "/wd4819,/EHsc,/W3,/nologo,/O2,/Zi" \
            -Xcompiler $$MSVCRT_LINK_FLAG_RELEASE
    }
}
linux {
    NVCCFLAGS = --cudart static
    NVCC_COMPILER_FLAGS = -Xcompiler -Wall
}
CONFIG(debug, debug|release) {
    # Debug mode
    cuda_d.input = CUDA_SOURCES
    cuda_d.output = $$CUDA_OBJECTS_DIR/${QMAKE_FILE_BASE}_cuda.obj
    cuda_d.commands = $$NVCC -D_DEBUG $$NVCC_OPTIONS $$CUDA_INC $$LIBS \
                      --machine $$SYSTEM_TYPE -arch=$$CUDA_ARCH \
                      $$NVCCFLAGS -g -G \
                      $$NVCC_COMPILER_FLAGS \
                      -c -o ${QMAKE_FILE_OUT} ${QMAKE_FILE_NAME}
    cuda_d.dependency_type = TYPE_C
    QMAKE_EXTRA_COMPILERS += cuda_d
}
else {
    # Release mode
    cuda.input = CUDA_SOURCES
    cuda.output = $$CUDA_OBJECTS_DIR/${QMAKE_FILE_BASE}_cuda.obj
    cuda.commands = $$CUDA_DIR/bin/nvcc.exe $$NVCC_OPTIONS $$CUDA_INC $$LIBS \
                    --machine $$SYSTEM_TYPE -arch=$$CUDA_ARCH \
                    $$NVCCFLAGS \
                    $$NVCC_COMPILER_FLAGS \
                    -c -o ${QMAKE_FILE_OUT} ${QMAKE_FILE_NAME}
    cuda.dependency_type = TYPE_C
    QMAKE_EXTRA_COMPILERS += cuda
}

SOURCES += \
    main.cpp
