Clonar repositório do GitLab :
	git clone https://github.com/nattgomes/laze

Instalar dependêndencias:
	sudo apt install python3-pip python3-venv postgresql wkhtmltopdf libpq-dev

Entrar na pasta do laze:
	cd laze

Clonado, criar ambiente virtual:
	python3 -m venv venv

Para ativar o ambiente virtual digite:
	source venv/bin/activate

Com o banco Postgres instalado execute:
	sudo -u postgres psql -f install/db.sql


Nas primeiras linhas do instal/db.sql está a criação do usuário que será utilizado para o database no postgres, se for alterado, modificar no arquivo config.py o parâmetro SQLALCHEMY_DATABASE_URI e a configuração do banco no arquivo service/laze.json.

Instalar dependências:
	pip install -r install/requirements.txt

Rodar a aplicação com o comando:
	 flask run

Acessar no navegador com localhost:5000

Use o usuário admin, senha admin para acessar o sistema

Clique em Adicionar Log e faça o upload do arquivo de log desejado, no momento ainda não foi implementado um parser automático para a ferramenta

Quando é feito um upload de arquivo a rota /parse executa o script em go que por sua vez executa a função do banco. 

Ainda, é adicionada na tablela files o timestamp do upload, nome do arquivo e o arquivo propriamente dito(large object). 

Existe trigger que, "for each statement" resultante de insert ou update na tabela files executa refresh nas views usadas na dashboard.

As views da dashboard também podem ser atualizadas através do menu "atualizar dashboard".

Obs.: Este tutorial foi testado no ubuntu 20.04
