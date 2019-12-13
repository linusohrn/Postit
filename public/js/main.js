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
        var randomcolor = '#'+(Math.random()*0xFFFFFF<<0).toString(16);
        if (randomcolor.length < 7){
            randomcolor += 0
        }
        console.log(randomcolor)
        messages[i].style.background = `${randomcolor}`;
    }
}
