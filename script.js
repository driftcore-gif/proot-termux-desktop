```javascript
document.addEventListener("DOMContentLoaded", () => {

    console.log("proot-termux-desktop loaded");

    const cards = document.querySelectorAll(".card");

    cards.forEach(card => {
        card.addEventListener("mouseenter", () => {
            card.style.scale = "1.02";
        });

        card.addEventListener("mouseleave", () => {
            card.style.scale = "1";
        });
    });

});
```
