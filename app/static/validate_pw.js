var actual_pw, new_pw, verify_pw;

var test = new Array(false, false, false);

function validate_btn2() {
    var submitButton = document.getElementById('pw_update_btn');

    for (i = 0; i < test.length; i++) {
        if (test[i] == false) {
            submitButton.setAttribute('disabled', 'disabled');
            break;
        }
        submitButton.removeAttribute('disabled');
    }
}


function validate_actual_pw() {
    password = document.getElementById("senha_atual").value;
    var error = document.getElementsByClassName("errorPW0")[0];
    if (password == "") {
        error.style.display = "inline-block";
        error.textContent = "Este campo é obrigatório.";
        test[0] = false;
    } else {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (this.readyState == 4) {
                if (this.status == 200) {
                    if (this.responseText == 0) {
                        error.style.display = "none";
                        test[0] = true;
                    } else {
                        error.style.display = "inline-block";
                        error.textContent = "Senha incorreta!!";
                        test[0] = false;
                    }
                }
            }
        };
        // Chama a rota de teste
        xhr.open('POST', '/validateActualPW', true);
        var data = new FormData();
        data.append("password", password)
        xhr.send(data)
    }
validate_btn2();
}

function validate_new_pw() {
    new_password = document.getElementById("senha_nova").value;
    var error = document.getElementsByClassName("errorPW1")[0];
    if (password == "") {
        error.style.display = "inline-block";
        error.textContent = "Este campo é obrigatório.";
        test[1] = false;
    } else {
        var regex = /^[a-zA-Z0-9_-]{3,20}$/i;
        if (regex.test(new_password)) {
            error.style.display = "none";
            test[1] = true;
        } else {
            error.style.display = "inline-block";
            error.textContent = "Senha inválida.";
            test[1] = false;
        }
    }
    validate_btn2();
}


function validate_verify_pw() {
    verify = document.getElementById("senha_verificacao").value;
    var error = document.getElementsByClassName("errorPW2")[0];
    if (verify == "") {
        error.style.display = "inline-block";
        error.textContent = "É preciso confirmar a senha escolhida.";
        test[2] = false;
    } else {
        if (new_password == verify) {
            error.style.display = "none";
            test[2] = true;
        } else {
            error.style.display = "inline-block";
            error.textContent = "Senha não corresponde à anteriormente digitada.";
            test[2] = false;
        }
    }
    validate_btn2();
}