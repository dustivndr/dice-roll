function showDice(diceValue) {
	const diceDisplay = document.getElementById('dice-display');
	if (!diceDisplay) return;
	diceDisplay.textContent = `\n    +---+\n    | ${diceValue} |\n    +---+ \n`;
}

function shakeDice(callback) {
	const n = Math.floor(Math.random() * 10) + 5;
	let i = 0;
	let diceValue = 1;
	const diceDisplay = document.getElementById('dice-display');
	const interval = setInterval(() => {
		diceValue = Math.floor(Math.random() * 6) + 1;
		showDice(diceValue);
		i++;
		if (i >= n) {
			clearInterval(interval);
			if (callback) callback(diceValue);
		}
	}, 100);
}

window.onload = function() {
	let diceValue = 1;
	showDice(diceValue);
	const rollOption = document.getElementById('roll-option');
	const exitOption = document.getElementById('exit-option');
	rollOption.addEventListener('click', function() {
		rollOption.classList.add('disabled');
		shakeDice(function(value) {
			diceValue = value;
			showDice(diceValue);
			rollOption.classList.remove('disabled');
		});
	});
	exitOption.addEventListener('click', function() {
		window.close();
	});
	// Keyboard navigation for accessibility
	[rollOption, exitOption].forEach((el, idx, arr) => {
		el.tabIndex = 0;
		el.addEventListener('keydown', function(e) {
			if (e.key === 'Enter' || e.key === ' ') {
				e.preventDefault();
				el.click();
			} else if (e.key === 'ArrowDown') {
				e.preventDefault();
				arr[(idx + 1) % arr.length].focus();
			} else if (e.key === 'ArrowUp') {
				e.preventDefault();
				arr[(idx - 1 + arr.length) % arr.length].focus();
			}
		});
	});
};