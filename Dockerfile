FROM quay.io/fenicsproject/stable:current

# Copy the current directory contents into the container
COPY . /home/fenics/shared

# Set the working directory
WORKDIR /home/fenics/shared

# Install any additional packages
RUN apt-get update && \
    apt-get install -y python3 python3-pip gmsh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies from requirements.txt if available
COPY requirements.txt /home/fenics/shared/requirements.txt
RUN if [ -f requirements.txt ]; then pip3 install -r requirements.txt; fi

# Set up Jupyter Notebook
RUN pip3 install jupyter

# Set the password for Jupyter Notebook
ENV PS=""
# Expose the Jupyter Lab port
EXPOSE 8888

# Start Jupyter Lab
CMD ["jupyter notebook --NotebookApp.ip='0.0.0.0' --port=8888 --no-browser --allow-root --NotebookApp.password='' --NotebookApp.token=''"]
