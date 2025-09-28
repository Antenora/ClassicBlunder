/globalTracker/var/MOTD_MESSAGE = "welcome to dimitri dbr."
#define CODER_MESSAGE "<img src='https://i.ibb.co/1tg5Tbn0/Screenshot-2025-03-27-005046.png'>"
/globalTracker/var/MOTD_HTML = {"<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MOTD</title>
</head>
<body style="background-color: #121212; color: #ffffff;">
    <table border="1" cellpadding="10" cellspacing="0" style="width: 100%; text-align: center;">
        <tr>
            <td colspan="3" style="font-size: 24px; font-weight: bold;">MOTD</td>
        </tr>
        <tr>
            <td style="font-size: 18px;">🌟</td>
            <td style="font-size: 20px; font-style: italic;">From the coders:</td>
            <td style="font-size: 18px;">🌟</td>
        </tr>
        <tr>
            <td colspan="3" style="font-size: 16px;">coder_message</td>
        </tr>
        <tr>
            <td style="font-size: 18px;">🌟</td>
            <td style="font-size: 20px; font-style: italic;">From the wipe runners:</td>
            <td style="font-size: 18px;">🌟</td>
        </tr>
        <tr>
            <td colspan="3" style="font-size: 16px;">motd_message</td>
        </tr>
    </table>
</body>
</html>
"}
/globalTracker/proc/getMOTD()
    var/html = replacetext(MOTD_HTML, "coder_message", CODER_MESSAGE)
    html = replacetext(html, "motd_message", MOTD_MESSAGE)
    return html
