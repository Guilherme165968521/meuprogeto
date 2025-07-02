// 'bolt_pedselector' by Bolt
// Script da UI que gerencia a interatividade do painel.

const container = document.getElementById('container');
const pedGrid = document.getElementById('ped-grid');

// Função para enviar dados para o cliente Lua
function post(event, data = {}) {
    return fetch(`https://${GetParentResourceName()}/${event}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data),
    });
}

// Escuta mensagens do cliente Lua
window.addEventListener('message', (event) => {
    const item = event.data;

    if (item.type === "ui") {
        if (item.status) {
            container.classList.remove('hidden');
        } else {
            container.classList.add('hidden');
        }
    }

    if (item.type === "setup") {
        setupPedGrid(item.peds);
    }
});

// Popula o grid com os peds da configuração
function setupPedGrid(peds) {
    pedGrid.innerHTML = ''; // Limpa o grid
    peds.forEach(ped => {
        const card = document.createElement('div');
        card.classList.add('ped-card');
        card.dataset.model = ped.model;
        card.innerText = ped.name;

        card.addEventListener('click', function() {
            post('selectPed', { model: this.dataset.model });
        });

        pedGrid.appendChild(card);
    });
}

// Escuta a tecla 'Escape' para fechar o painel
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        container.classList.add('hidden');
        post('close');
    }
});
