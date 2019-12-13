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