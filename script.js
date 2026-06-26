document.addEventListener("DOMContentLoaded", () => {
    console.log("proot-termux-desktop loaded");

    document.querySelectorAll(".card").forEach(card => {
        card.addEventListener("click", () => {
            card.style.transform = "scale(1.03)";
            setTimeout(() => {
                card.style.transform = "";
            }, 150);
        });
    });
});
