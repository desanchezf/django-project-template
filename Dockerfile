# Versión de linux que se va a utilizar dentro del container
FROM python:3.12-bookworm
# FROM python:3.12-bookworm -> Por ahora incomplatible con el tema

# Evita la generación de archivos de bytecode (.pyc)
ENV PYTHONDONTWRITEBYTECODE 1
# Evita el almacenamiento en búfer de la salida y el error estándar
ENV PYTHONUNBUFFERED 1

# Instalar dependencias del sistema y herramientas de compilación
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    gettext \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instalar UV usando pip (más confiable en contenedores)
RUN pip install uv

RUN mkdir /code
WORKDIR /code

# Copiar solo requirements.txt primero para aprovechar cache de Docker
COPY requirements.txt /code/

# Usar UV para instalar dependencias (mucho más rápido que pip)
# --system: instala en el sistema Python
# --no-cache: evita cache local para builds más limpios
RUN uv pip install --system --no-cache -r requirements.txt

# Instalar herramientas adicionales
RUN apt-get update && apt-get install -y htop && rm -rf /var/lib/apt/lists/*

# Memory management
ENV PYTHONMALLOC=malloc
ENV MALLOC_ARENA_MAX=2
ENV PYTHONHASHSEED=random

# Optimizar garbage collection
ENV PYTHONGC=1

COPY . /code/
