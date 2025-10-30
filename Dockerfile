FROM quay.io/fenicsproject/stable:current

# Install any additional packages
RUN apt-get update && \
    apt-get install -y python3 python3-pip gmsh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir \
    jupyterlab \
    notebook \
    ipykernel \
    ipywidgets \
    matplotlib \
    numpy \
    scipy \
    pandas \
    meshio \
    pyvista \
    ipyparallel

# Set the working directory
WORKDIR /workspace

# Создаем пользователя fenics
RUN useradd -m -s /bin/bash -G sudo fenics || true && \
    echo "fenics ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


# Настраиваем права доступа
RUN chmod -R 777 /workspace && \
    mkdir -p /home/fenics/.jupyter && \
    chown -R fenics:fenics /home/fenics && \
    chown -R fenics:fenics /workspace

# Настраиваем ipyparallel для работы с MPI
RUN ipython profile create --parallel --profile=mpi || true
RUN su - fenics -c "/opt/conda/envs/fenics-legacy/bin/ipython profile create --parallel --profile=mpi" || true

# Копируем конфигурацию Jupyter для пользователя fenics с base_url
RUN mkdir -p /home/fenics/.jupyter && \
    echo "c.ServerApp.ip = '0.0.0.0'" >> /home/fenics/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.port = 8888" >> /home/fenics/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.base_url = '/fenics-legacy/'" >> /home/fenics/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_root = False" >> /home/fenics/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.token = ''" >> /home/fenics/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.password = ''" >> /home/fenics/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_origin = '*'" >> /home/fenics/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.disable_check_xsrf = True" >> /home/fenics/.jupyter/jupyter_lab_config.py && \
    chown -R fenics:fenics /home/fenics/.jupyter

# Переключаемся на пользователя fenics
USER fenics

# Открываем порт для Jupyter Lab
EXPOSE 8888

# Запуск Jupyter Lab от пользователя fenics с base_url
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--base-url=/fenics-legacy/"]
