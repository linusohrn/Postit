function CopyToClipboard(id)
{
    const el = document.createElement('textarea');
    el.value = `localhost:9292/users/1/wall#message_id=${id}`;
    document.body.appendChild(el);
    el.select();
    document.execCommand('copy');
    document.body.removeChild(el);
};

function goBack() 
{
    window.history.back();
}

function randcolor()
{
    messages = document.getElementsByClassName("message")
    for (i=0;i < messages.length; i++){
        val = Math.round(Math.random() * 4)
        console.log(val)
        if (val == 1) {
            randomcolor = "#aed143"
        } else if (val == 2) {
            randomcolor = "#fbd249"
        } else if (val == 3) {
            randomcolor = "#f49f3f"
        } else if (val == 4) {
            randomcolor = "#d35595"
        } else if (val == 0) {
            randomcolor = "#51bcb3"
        }
        messages[i].style.background = `${randomcolor}`;
    }
}
    