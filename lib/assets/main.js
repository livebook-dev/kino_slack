export function init(ctx, payload) {
  ctx.root.innerHTML = `
   <label for="token">Token</label>
   <input id="token" type="text">

   <label for="channel">Channel</label>
   <input id="channel" type="text">

   <label for="message">Message</label>
   <input id="message" type="text">
  `;

  console.log(payload)

  const tokenEl = document.getElementById("token");
  tokenEl.value = payload.fields.token;

  const channelEl = document.getElementById("channel");
  channelEl.value = payload.fields.channel;

  const messageEl = document.getElementById("message");
  messageEl.value = payload.fields.message;

  tokenEl.addEventListener("change", (event) => {
    ctx.pushEvent("update_token", event.target.value)
  });

  channelEl.addEventListener("change", (event) => {
    ctx.pushEvent("update_channel", event.target.value)
  });

  messageEl.addEventListener("change", (event) => {
    ctx.pushEvent("update_message", event.target.value)
  });

  ctx.handleSync(() => {
    // Synchronously invokes change listeners
    document.activeElement &&
      document.activeElement.dispatchEvent(new Event("change"));
  });
}
