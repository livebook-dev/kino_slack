export function init(ctx, payload) {
  ctx.root.innerHTML = `
   <label for="token">Token</label>
   <input id="token" type="text" readonly>

   <label for="channel">Channel</label>
   <input id="channel" type="text">

   <label for="message">Message</label>
   <input id="message" type="text">
  `;

  console.log(payload)

  const tokenEl = document.getElementById("token");
  tokenEl.value = payload.fields.token_secret_name;

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

  tokenEl.addEventListener("click", (event) => {
    ctx.selectSecret((secret_name) => {
      ctx.pushEvent("update_token_secret_name", secret_name);
    }, "SLACK_TOKEN")
  });

  ctx.handleEvent("update_token_secret_name", (token_secret_name) => {
    tokenEl.value = token_secret_name;
  });

  ctx.handleSync(() => {
    // Synchronously invokes change listeners
    document.activeElement &&
      document.activeElement.dispatchEvent(new Event("change"));
  });
}
