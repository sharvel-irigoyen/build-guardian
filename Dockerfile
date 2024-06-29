# Usa la imagen base de PHP con FPM
FROM php:8.2-fpm

# Instala dependencias y extensiones necesarias
RUN apt-get update && apt-get install -y \
    unzip \
    zip \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    nodejs \
    npm \
    nano

# Instala extensiones PHP necesarias
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Instala la extensión de MongoDB
RUN pecl install mongodb
# Habilita la extensión de MongoDB
RUN docker-php-ext-enable mongodb

# Instala Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

# Instala Node.js y npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs

# Instala las dependencias de Composer
WORKDIR /var/www/build-guardian

# Copia el código fuente de la aplicación
COPY . /var/www/build-guardian
RUN composer install --no-plugins --no-scripts --no-interaction

# Copia el archivo de entorno
COPY .env.example .env

# Genera la clave de la aplicación
RUN php artisan key:generate

# Crea el enlace simbólico para el almacenamiento
RUN php artisan storage:link

# Permisos de escritura
RUN chmod 777 -R storage bootstrap

# Instala las dependencias de npm
RUN npm install

# Compila los assets
RUN npm run build

# Expone el puerto 9000
EXPOSE 9000
