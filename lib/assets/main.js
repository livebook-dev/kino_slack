export function init(ctx, payload) {
  ctx.importCSS("main.css");
  ctx.importCSS(
    "https://fonts.googleapis.com/css2?family=Inter:wght@400;500&display=swap"
  );

  ctx.root.innerHTML = `
    <div class="app">
      <form>
        <div class="container">
          <div class="row header">
            <div class="inline-field">
              <label class="inline-input-label">Slack token</label>
              <input class="input input--xs input-text" id="token" placeholder="xoxb-something"readonly>
            </div>
            <div class="inline-field">
              <label class="inline-input-label">Slack channel</label>
              <input class="input input--xs input-text" id="channel" placeholder="#channel-name">
            </div>
          </div>
          <div class="row">
            <div class="field grow">
              <label class="input-label">Message</label>
              <textarea id="message" rows="10" class="input input--text-area" placeholder="Insert your slack mesage here..."></textarea>
            </div>
          </div>
        </div>
      </form>
    </div>
  `;

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
