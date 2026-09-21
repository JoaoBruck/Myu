const evidence = {
  river: {
    title: "Foto do rio",
    type: "Fotografia",
    origin: "Arquivo sem identificação",
    state: "Preservada",
    relevance: "Baixa",
    observation: "O enquadramento não bate com o caminho principal."
  },
  letter: {
    title: "Carta queimada",
    type: "Documento",
    origin: "Casa-lar",
    state: "Parcialmente destruída",
    relevance: "Não confirmada",
    observation: "As marcas de pressão continuam onde a tinta já não existe."
  },
  van: {
    title: "Van de Vicente",
    type: "Registro",
    origin: "Coordenador Vicente",
    state: "Incompleto",
    relevance: "Média",
    observation: "O dano aparece antes do horário informado."
  },
  reservoir: {
    title: "Reservatório",
    type: "Lugar",
    origin: "Bairro",
    state: "Desativado",
    relevance: "Alta",
    observation: "Ninguém comenta o lugar. Ainda assim, várias pistas começam a convergir."
  }
};

const cards = document.querySelectorAll(".evidence-card");

cards.forEach(card => {
  card.addEventListener("click", () => {
    cards.forEach(c => c.classList.remove("selected"));
    card.classList.add("selected");

    const data = evidence[card.dataset.evidence];
    document.querySelector("#inspector-title").textContent = data.title;
    document.querySelector("#fact-type").textContent = data.type;
    document.querySelector("#fact-origin").textContent = data.origin;
    document.querySelector("#fact-state").textContent = data.state;
    document.querySelector("#fact-relevance").textContent = data.relevance;
    document.querySelector("#observation-text").textContent = data.observation;
  });
});

document.querySelectorAll(".nav-item").forEach(item => {
  item.addEventListener("click", () => {
    document.querySelectorAll(".nav-item").forEach(i => i.classList.remove("active"));
    item.classList.add("active");
  });
});
