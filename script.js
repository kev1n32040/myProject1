let score = 0;
let clickValue = parseInt(localStorage.getItem('clickValue')) || 1;
const scoreElement = document.getElementById('score');
const clickBtn = document.getElementById('clickBtn');
const notification = document.getElementById('notification');
const upgradeContainer = document.getElementById('upgradeContainer');

// Загружаем сохраненный счет и состояние улучшения при запуске
if (localStorage.getItem('clickerScore')) {
    score = parseInt(localStorage.getItem('clickerScore'));
    scoreElement.textContent = score;
    if (localStorage.getItem('upgradeUsed') !== 'true') {
        checkUpgrades();
    }
}

function showNotification(message) {
    notification.textContent = message;
    notification.classList.add('show');
    
    setTimeout(() => {
        notification.classList.remove('show');
    }, 5000);
}

function createUpgradeButton() {
    const button = document.createElement('button');
    button.className = 'upgrade-button';
    button.textContent = 'Удвоить клики!';
    button.addEventListener('click', () => {
        clickValue *= 2;
        localStorage.setItem('clickValue', clickValue);
        button.remove();
        localStorage.setItem('upgradeUsed', 'true');
        showNotification('Теперь каждый клик дает в 2 раза больше очков!');
    });
    upgradeContainer.appendChild(button);
    setTimeout(() => button.classList.add('show'), 100);
}

function checkUpgrades() {
    if (score >= 1000 && !document.querySelector('.upgrade-button') && localStorage.getItem('upgradeUsed') !== 'true') {
        createUpgradeButton();
    }
}

function checkMilestones() {
    const milestones = [10, 100, 500, 1000, 5000, 10000, 50000, 100000, 500000, 1000000, 5000000, 10000000, 50000000, 100000000, 500000000, 1000000000, 5000000000, 10000000000, 50000000000, 100000000000, 500000000000, 1000000000000, 5000000000000, 10000000000000, 50000000000000, 100000000000000, 500000000000000, 1000000000000000, 5000000000000000, 10000000000000000, 50000000000000000, 100000000000000000, 500000000000000000, 1000000000000000000, 5000000000000000000, 10000000000000000000];
    if (milestones.includes(score)) {
        showNotification(`Поздравляем! Вы достигли ${score} кликов! Вы молодец!`);
    }
}

clickBtn.addEventListener('click', () => {
    score += clickValue;
    scoreElement.textContent = score;
    
    // Сохраняем счет
    localStorage.setItem('clickerScore', score);
    
    // Проверяем достижения и улучшения
    checkMilestones();
    checkUpgrades();
    
    // Добавляем эффект при клике
    clickBtn.style.transform = 'scale(0.95)';
    setTimeout(() => {
        clickBtn.style.transform = 'scale(1)';
    }, 100);
});
