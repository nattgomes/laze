var name, lastname, cpf, phone, user, email, password, verify;

// var tests = [tested_name, tested_lastname, tested_cpf, tested_phone, tested_user, tested_email, tested_password, tested_verify];
var tests = new Array(false, false, false, false, false, false, false, false);

function validate_btn() {
    var submitButton = document.getElementById('signup_btn');

    for (i = 0; i < tests.length; i++) {
        if (tests[i] == false) {
            submitButton.setAttribute('disabled', 'disabled');
            // console.log("negativo");
            break;
        }
        submitButton.removeAttribute('disabled');
        // console.log("positivo");
    }

}

function validate_name() {
    name = document.getElementById("name").value;
    var error = document.getElementsByClassName("errorName")[0];
    if (name == "") {
        error.style.display = "inline-block";
        error.textContent = "Este campo é obrigatório.";
        tests[0] = false;
    } else if (name.length < 3) {
        error.style.display = "inline-block";
        error.textContent = "O nome deve conter mais de duas letras.";
        tests[0] = false;
    } else {
        var regex = /^[a-z]+$/i;
        if (regex.test(name)) {
            error.style.display = "none";
            tests[0] = true;
            // validate_btn();
        } else {
            error.style.display = "inline-block";
            error.textContent = "Nome inválido. Digite apenas letras.";
            tests[0] = false;
        }
    }
    validate_btn();
}

function validate_lastname() {
    lastname = document.getElementById("lastname").value;
    var error = document.getElementsByClassName("errorLastName")[0];
    if (lastname == "") {
        error.style.display = "inline-block";
        error.textContent = "Este campo é obrigatório.";
        tests[1] = false;
    } else if (lastname.length < 2) {
        error.style.display = "inline-block";
        error.textContent = "O sobrenome deve conter pelo menos duas letras.";
        tests[1] = false;
    } else {
        var regex = /^[a-z]+$/i;
        if (regex.test(lastname)) {
            error.style.display = "none";
            tests[1] = true;
            // validate_btn();
        } else {
            error.style.display = "inline-block";
            error.textContent = "Sobrenome inválido. Digite apenas letras.";
            tests[1] = false;
        }
    }
    validate_btn();
}

function validate_cpf() {
    cpf = document.getElementById("cpf").value;
    var error = document.getElementsByClassName("errorCPF")[0];
    if (cpf == "") {
        error.style.display = "inline-block";
        error.textContent = "Este campo é obrigatório.";
        tests[2] = false;
    } else {
        var regex = /^[0-9]{11}$/i;
        if (regex.test(cpf)) {
            error.style.display = "none";
            tests[2] = true;
            // validate_btn();
        } else {
            error.style.display = "inline-block";
            error.textContent = "O campo CPF deve conter 9 dígitos.";
            tests[2] = false;
        }
    }
    validate_btn();
}

function validate_phone() {
    phone = document.getElementById("phone").value;
    var error = document.getElementsByClassName("errorPhone")[0];
    if (phone == "") {
        error.style.display = "inline-block";
        error.textContent = "Este campo é obrigatório.";
        tests[3] = false;
    } else {
        var regex = /^[0-9]{9}$/i;
        if (regex.test(phone)) {
            error.style.display = "none";
            tests[3] = true;
            // validate_btn();
        } else {
            error.style.display = "inline-block";
            error.textContent = "Digite apenas números. O telefone deve conter apenas 9 dígitos.";
            tests[3] = false;
        }
    }
    validate_btn();
}

function validate_username() {
    username = document.getElementById("username").value;

    var error = document.getElementsByClassName("errorUser")[0];
    if (username == "") {
        error.style.display = "inline-block";
        error.textContent = "Este campo é obrigatório.";
        tests[4] = false;
    } else if (username.length < 2) {
        error.style.display = "inline-block";
        error.textContent = "O nome de usuário deve conter pelo menos duas letras.";
        tests[4] = false;
    } else {
        var regex = /^[a-z0-9_-]+$/i;
        if (regex.test(username)) {
            var xhr = new XMLHttpRequest();

            // pq isso fica antes se executa após o open e o send?
            xhr.onreadystatechange = function () {
                if (this.readyState == 4) {
                    if (this.status == 200) {
                        // usa-se responseText para ler o conteúdo do html?
                        if (this.responseText == 0) {
                            error.style.display = "none";
                            tests[4] = true;
                        } else {
                            error.style.display = "inline-block";
                            error.textContent = "Nome de usuario já em uso. Escolha outro.";
                            tests[4] = false;
                        }
                    }
                }
            };
            // Chama a rota de teste
            xhr.open('POST', '/validateNewUser', true);
            var data = new FormData();
            data.append("username", username)
            xhr.send(data)
        } else {
            error.style.display = "inline-block";
            error.textContent = "Nome de usuário inválido. Use somente letras e números.";
            tests[4] = false;
        }
    }
    validate_btn();
}

function validate_email() {
    email = document.getElementById("email").value;
    var error = document.getElementsByClassName("errorEmail")[0];
    if (email == "") {
        error.style.display = "inline-block";
        error.textContent = "Este campo é obrigatório.";
        tests[5] = false;
    } else {
        var regex = /^[\S]+@[\S]+\.[\S]+$/i;
        if (regex.test(email)) {
            error.style.display = "none";
            tests[5] = true;
            // validate_btn();
        } else {
            error.style.display = "inline-block";
            error.textContent = "Endereço de e-mail inválido.";
            tests[5] = false;
        }
    }
    validate_btn();
}


function validate_password() {
    password = document.getElementById("password").value;
    var error = document.getElementsByClassName("errorPassword")[0];
    if (password == "") {
        error.style.display = "inline-block";
        error.textContent = "Este campo é obrigatório.";
        tests[6] = false;
    } else {
        var regex = /^[a-zA-Z0-9_-]{3,20}$/i;
        if (regex.test(password)) {
            error.style.display = "none";
            tests[6] = true;
        } else {
            error.style.display = "inline-block";
            error.textContent = "Senha inválida.";
            tests[6] = false;
        }
    }
    validate_btn();
}


function validate_verify() {
    verify = document.getElementById("verify").value;
    var error = document.getElementsByClassName("errorVerify")[0];
    if (password == "") {
        error.style.display = "inline-block";
        error.textContent = "É preciso confirmar a senha escolhida.";
        tests[7] = false;
    } else {
        if (password == verify) {
            error.style.display = "none";
            tests[7] = true;
        } else {
            error.style.display = "inline-block";
            error.textContent = "Senha não corresponde à anteriormente digitada.";
            tests[7] = false;
        }
    }
    validate_btn();
}
