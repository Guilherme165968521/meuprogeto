// 'bolt_pedselector' by Bolt - v2.0.0 Script
const container = document.getElementById('container');
const pedGrid = document.getElementById('ped-grid');
const closeBtn = document.getElementById('close-btn');

let currentPeds = [];

// Função para enviar dados para o cliente Lua
async function post(event, data = {}) {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/${event}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(data),
        });
        return await response.json();
    } catch (error) {
        console.error('Failed to post NUI callback:', error);
        return { ok: false, error: error.message };
    }
}

// Renderiza todos os peds no grid
function renderPeds(peds) {
    pedGrid.innerHTML = ''; // Limpa o grid
    currentPeds = peds; // Armazena a lista de peds

    peds.forEach(ped => {
        const card = document.createElement('div');
        card.className = 'ped-card';
        card.id = `ped-${ped.id}`;

        const img = document.createElement('img');
        img.src = ped.image_url || 'https://via.placeholder.com/200x180.png?text=No+Image';
        img.onerror = () => { img.src = 'https://via.placeholder.com/200x180.png?text=No+Image'; };
        card.appendChild(img);

        const name = document.createElement('h3');
        name.textContent = ped.name;
        card.appendChild(name);

        if (!ped.purchased) {
            const price = document.createElement('p');
            price.className = 'price';
            price.textContent = `${ped.price.toLocaleString()} Coins`;
            card.appendChild(price);
        }

        const actions = document.createElement('div');
        actions.className = 'actions';
        card.appendChild(actions);

        updateCardActions(ped);
        pedGrid.appendChild(card);
    });
}

// Atualiza os botões de um card específico
function updateCardActions(ped) {
    const card = document.getElementById(`ped-${ped.id}`);
    if (!card) return;

    const actions = card.querySelector('.actions');
    actions.innerHTML = ''; // Limpa botões antigos

    if (ped.purchased) {
        const selectBtn = document.createElement('button');
        selectBtn.className = 'btn btn-select';
        selectBtn.textContent = 'Selecionar';
        selectBtn.onclick = () => post('selectPed', { model: ped.model });
        actions.appendChild(selectBtn);
    } else {
        const buyBtn = document.createElement('button');
        buyBtn.className = 'btn btn-buy';
        buyBtn.textContent = 'Comprar';
        buyBtn.onclick = () => post('buyPed', { id: ped.id });
        actions.appendChild(buyBtn);

        const testBtn = document.createElement('button');
        testBtn.className = 'btn btn-test';
        testBtn.textContent = 'Testar';
        testBtn.onclick = () => post('testPed', { model: ped.model });
        actions.appendChild(testBtn);
    }
}

// Fecha a UI
function closeUI() {
    container.classList.add('hidden');
    post('close');
}

// Escuta mensagens do cliente Lua
window.addEventListener('message', (event) => {
    const item = event.data;

    switch (item.type) {
        case "ui":
            container.classList.toggle('hidden', !item.status);
            break;
        case "setup":
            renderPeds(item.peds);
            break;
        case "updatePedStatus":
            const pedToUpdate = currentPeds.find(p => p.id === item.id);
            if (pedToUpdate) {
                pedToUpdate.purchased = true;
                const priceEl = document.querySelector(`#ped-${item.id} .price`);
                if (priceEl) priceEl.remove();
                updateCardActions(pedToUpdate);
            }
            break;
    }
});

// Event listeners para fechar
closeBtn.addEventListener('click', closeUI);
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeUI();
    }
});
