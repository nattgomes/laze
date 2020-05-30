Clonar repositório do GitLab :
	git clone https://gitlab.sertao.ifrs.edu.br/215171/laze.git

Clonado, criar ambiente virtual:
	python3 -m venv venv

Para ativar o ambiente virtual digite:
	source venv/bin/activate


Com o banco Postgres instalado execute:
	sudo -u postgres psql -f install/db.sql

Ir no arquivo config.py e alterar o parâmetro SQLALCHEMY_DATABASE_URI para sua conexão com o banco.

Alterar o arquivo service/laze.json também com as configurações do banco de dados.

Instalar dependências:
	pip install -r install/requirements.txt

Rodar a aplicação com o comando:
	 flask run

Acessar no navegador com localhost:5000

Use o usuário natt, senha natt para acessar o sistema

Clique em Adicionar Log e faça o upload do arquivo install/dump_squid.log



Na pasta sql você encontrará os arquivos de criação do banco, função que insere entradas no banco de dados após o parse realizado através do script em go, a criação de views e também a criação de trigger para refresh das views

Quando é feito um upload de arquivo a rota /parse executa o script em go que por sua vez executa a função do banco. 

Ainda, é adicionada na tablela files o timestamp do upload, nome do arquivo e o arquivo propriamente dito(large object). 

Existe trigger que, "for each statement" resultante de insert ou update na tabela files executa refresh nas views usadas na dashboard.

As views da dashboard também podem ser atualizadas através do menu "atualizar dashboard".