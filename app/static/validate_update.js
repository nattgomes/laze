var valid = true;

function validate_form(){

    validate_name()
    validate_lastname()
    validate_cpf()
    validate_phone()
    validate_email()

    if (valid == True)
        return valid;
}


function validate_name() {
    name = document.getElementById("name").value;
    var error  = document.getElementsByClassName("errorName")[0];
    if (name == "") {
        error.style.display = "inline-block";
        error.textContent = "Este campo é obrigatório.";
        valid = false;
    } else if (name.length < 3) {
        error.style.display = "inline-block";
        error.textContent = "O nome deve conter mais de duas letras.";
        valid = false;
    } else {
        var regex = /^[a-z]+$/i;
        if (regex.test(name)) {
            error.style.display = "none";
            valid = true;
        } else {
             error.style.display = "inline-block";
            error.textContent = "Nome inválido. Digite apenas letras.";
            valid = false;
        }
    }
}

function validate_lastname() {
    lastname = document.getElementById("lastname").value;
    var error  = document.getElementsByClassName("errorLastName")[0];
    if (lastname == "") {
        error.style.display = "inline-block";
        error.textContent = "Este campo é obrigatório.";
        valid = false;
    } else if (lastname.length < 2) {
        error.style.display = "inline-block";
        error.textContent = "O sobrenome deve conter pelo menos duas letras.";
        valid = false;
    } else {
        var regex = /^[a-z]+$/i;
        if (regex.test(lastname)) {
            error.style.display = "none";
            valid = true;
        } else {
             error.style.display = "inline-block";
            error.textContent = "Sobrenome inválido. Digite apenas letras.";
            valid = false;
        }
    }
}

function validate_cpf() {
    cpf = document.getElementById("cpf").value;
    var error  = document.getElementsByClassName("errorCPF")[0];
    if (cpf == "") {
        error.style.display = "inline-block";
        error.textContent = "Este campo é obrigatório.";
        valid = false;
    } else {
        var regex = /^[0-9]{11}$/i;
        if (regex.test(cpf)) {
            error.style.display = "none";
            valid = true;
        } else {
             error.style.display = "inline-block";
            error.textContent = "O campo CPF deve conter 9 dígitos.";
            valid = false;
        }
    }
}

function validate_phone() {
    phone = document.getElementById("phone").value;
    var error  = document.getElementsByClassName("errorPhone")[0];
    if (phone == "") {
        error.style.display = "inline-block";
        error.textContent = "Este campo é obrigatório.";
        valid = false;
    } else {
        var regex = /^[0-9]{9}$/i;
        if (regex.test(phone)) {
            error.style.display = "none";
            valid = true;
        } else {
             error.style.display = "inline-block";
            error.textContent = "Digite apenas números. O telefone deve conter apenas 9 dígitos.";
            valid = false;
        }
    }
}


function validate_email() {
    email = document.getElementById("email").value;
    var error  = document.getElementsByClassName("errorEmail")[0];
    if (email == "") {
        error.style.display = "inline-block";
        error.textContent = "Este campo é obrigatório.";
        valid = false;
    } else {
        var regex = /^[\S]+@[\S]+\.[\S]+$/i;
        if (regex.test(email)) {
            error.style.display = "none";
            valid = true;
        } else {
            error.style.display = "inline-block";
            error.textContent = "Endereço de e-mail inválido.";
            valid = false;
        }
    }
}
