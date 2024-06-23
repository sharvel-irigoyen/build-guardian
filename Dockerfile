FROM php:8.2-fpm

# Instala dependencias comunes de extensiones PHP
RUN apt-get update && apt-get install -y \
    netcat-openbsd \
    libfreetype-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    zlib1g-dev \
    libzip-dev \
    unzip \
    curl \
    gnupg \
    pkg-config \
    libssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_mysql \
    && docker-php-ext-install zip \
    && docker-php-ext-install bcmath \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb

# Instala Node.js y npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Establece el directorio de trabajo
WORKDIR /var/www/app

# Copia el código fuente de la aplicación
COPY . /var/www/app

# Asigna permisos adecuados
RUN chown -R www-data:www-data /var/www/app \
    && chmod -R 777 /var/www/app/storage \
    && chmod -R 777 /var/www/app/bootstrap/cache

# Copia y instala Composer
COPY --from=composer:2.6.5 /usr/bin/composer /usr/local/bin/composer

# Copia composer.json y package.json al directorio de trabajo e instala dependencias
COPY composer.json ./
COPY package.json ./
RUN composer upgrade && npm install

# Expone el puerto (si tu aplicación corre en un puerto específico)
EXPOSE 3000

# Establece el comando por defecto para correr php-fpm
CMD ["php-fpm"]
