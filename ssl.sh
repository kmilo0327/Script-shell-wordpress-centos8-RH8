echo "######################################################################################"
echo "# Creado por kmilo0327, si falla al momento de iniciar certbot reinicia el proceso   #"
echo "######################################################################################"

echo -e "\n\n*** Instalando modulo SSL..."
yum install snapd mod_ssl openssl -y

echo -e "\n\n*** Instalando SNAP"
systemctl enable --now snapd.socket
ln -s /var/lib/snapd/snap /snap
systemctl start snapd.seeded.service
snap install core
snap refresh core

echo -e "\n\n*** Configurando CERTBOT"
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
certbot --apache
systemctl restart httpd
