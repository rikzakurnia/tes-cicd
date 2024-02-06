# Use an official PHP runtime as a base image
FROM php:8.3-apache

# Set the working directory in the container
WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy the composer files and install dependencies
COPY composer.json composer.lock ./
RUN composer install --prefer-dist --no-scripts --no-dev --no-autoloader
RUN composer require --dev phpunit/phpunit || true
RUN composer require --dev roave/security-advisories:dev-latest || true

# Copy the application files to the container
COPY . .

# Set up Apache to serve the Laravel application
RUN a2enmod rewrite
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

# Set up Laravel
RUN cp .env.example .env
RUN php artisan key:generate

# Set permissions for Laravel
RUN chown -R www-data:www-data storage bootstrap/cache

# Expose port 80 and start Apache
EXPOSE 80
CMD ["apache2-foreground"]
