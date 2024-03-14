alert('Hi My brothe');

fetch('http://127.0.0.1:5000/usuarios').then(
    (res) => res.json()
).then((res) => console.log(res.usuarios))


cards = document.getElementsByClassName('card');

for(card of cards){
    card.addEventListener('click',()=>{
        alert('Hi');
    })
}