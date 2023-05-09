const form = document.getElementById("callsign-form");
const toggleBtn1 = document.querySelector('#toggle-btn-1');
const toggleBtn2 = document.querySelector('#toggle-btn-2');
const sliders = document.querySelectorAll('.skidder');
const officersBox = document.getElementById('officers-box');
const root = document.querySelector(':root');

dragElement(document.getElementById("white-box"), document.querySelector(".header"));
dragElement(document.getElementById("officers-box"), document.querySelector(".header-box"));

sliders.forEach(slider => {
  const sliderValue = slider.value;
  const sliderMax = slider.max;
  slider.style.setProperty('--value', ((sliderMax - sliderValue) / sliderMax) * 100 + '%');
  if (slider.dataset.name === "background-opacity") {
    officersBox.style.setProperty('--background-opacity', `${sliderValue}` / 100);
  } else if (slider.dataset.name === "system-scale") {
    officersBox.style.setProperty('--system-scale', `${sliderValue}` / 100);
  }
  slider.addEventListener('input', function() {
    slider.style.setProperty('--value', ((sliderMax - this.value) / sliderMax) * 100 + '%');
  });
  slider.addEventListener('change', function() {
    const sliderName = slider.dataset.name;
    const sliderValue = slider.value;
    if (sliderName === "background-opacity") {
      officersBox.style.setProperty('--background-opacity', `${sliderValue}` / 100);
    } else if (sliderName === "system-scale") {
      officersBox.style.setProperty('--system-scale', `${sliderValue}` / 100);
    }
  });
});

$(document).ready(function() {
  $('.white-box').hide();
});

document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape' || event.key === 'Backspace')
    HideUserInterface()
});

$('.close-btn').click(function() {
  HideUserInterface();
});

function ShowUserInterface() {
  $('.white-box').show();
}

function HideUserInterface() {
  $('.white-box').hide();
  $.post(`https://${GetParentResourceName()}/HideUserInterface`);
}

function dragElement(elmnt, header) {
  var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
  header.onmousedown = dragMouseDown;
  function dragMouseDown(e) {
    e = e || window.event;
    e.preventDefault();
    pos3 = e.clientX;
    pos4 = e.clientY;
    document.onmouseup = closeDragElement;
    document.onmousemove = elementDrag;
  }
  function elementDrag(e) {
    e = e || window.event;
    e.preventDefault();
    pos1 = pos3 - e.clientX;
    pos2 = pos4 - e.clientY;
    pos3 = e.clientX;
    pos4 = e.clientY;
    elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
    elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
  }
  function closeDragElement() {
    document.onmouseup = null;
    document.onmousemove = null;
  }
}

function refreshOfficersList(activeOfficers) {
  const officersListElement = document.getElementById('officers-list');
  officersListElement.innerHTML = ''; 
  if (activeOfficers) {
    for (const officer of activeOfficers) {
      const officerElement = document.createElement('div');
      officerElement.classList.add('officer');
      const onDutyIcon = '<i class="fa-solid fa-user-clock" style="color: #1B4D3E;"></i>';
      const offDutyIcon = '<i class="fa-solid fa-user-clock" style="color: #7C0A02;"></i>';
      officerElement.innerHTML = `
        <span>
          ${officer.rank} ${officer.badgeNumber} - ${officer.name}
          <span style="margin-left: 5px">
            ${officer.onDuty ? onDutyIcon : offDutyIcon}
          </span>
        </span>
      `;
      officersListElement.appendChild(officerElement);
    }
  }
}

window.addEventListener('message', function(event) {
  switch(event.data.action) {
    case "ShowUserInterface":
      ShowUserInterface();
      const playerName = event.data.playerName;
      const playerRank = event.data.playerRank;
      const playerCallsign = event.data.playerCallsign;
      const playerInfoElement = document.getElementById('player-info');
      playerInfoElement.innerHTML = `${playerRank} ${playerCallsign}, ${playerName}.`;
      refreshOfficersList(event.data.activeOfficers);
    break;
    case "RefreshList":
      refreshOfficersList(event.data.activeOfficers);
    break;
  }
});

window.addEventListener('message', function(event) {
  switch(event.data.action) {
    case "HideUserInterface":
      HideUserInterface();
    break;
  }
});

toggleBtn2.addEventListener('click', () => {
  toggleBtn2.classList.toggle('active');
  if (toggleBtn2.classList.contains('active')) {
    root.style.setProperty('--primary-color', '#121212');
    root.style.setProperty('--secondary-color', '#f2f2f2');
    root.style.setProperty('--hover-color', '#303030');
    root.style.setProperty('--accent-color', '#f2f2f2');
    root.style.setProperty('--accent-color2', '#1c1c1c');
    root.style.setProperty('--accent-color3', '#6b6b6b');
    root.style.setProperty('--accent-color4', '#999999');
  } else {
    root.style.setProperty('--primary-color', '#ffffff');
    root.style.setProperty('--secondary-color', '#333333');
    root.style.setProperty('--hover-color', '#D9D9D9');
    root.style.setProperty('--accent-color', '#030303');
    root.style.setProperty('--accent-color2', '#f2f2f2');
    root.style.setProperty('--accent-color3', '#C1C1C1');
    root.style.setProperty('--accent-color4', '#ccc');
  }
});

toggleBtn1.addEventListener('click', () => {
  toggleBtn1.classList.toggle('active');
  if (toggleBtn1.classList.contains('active')) {
    officersBox.style.display = 'block';
  } else {
    officersBox.style.display = 'none';
  }
});

form.addEventListener("submit", (event) => {
  event.preventDefault();
  const callsign = form.elements.callsign.value;
  $.post(`https://${GetParentResourceName()}/setCallsign`, JSON.stringify({
    callsign: callsign
  }), function(data){
  });
});