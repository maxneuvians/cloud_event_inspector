import { Socket } from "phoenix";

let socket = new Socket("/socket", { params: { token: window.userToken } });

socket.connect();

let channel = socket.channel("room:lobby", {});
let matched = document.querySelector("#matched");
let invalid = document.querySelector("#invalid");
let total = document.querySelector("#total");

channel
  .join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp);
  })
  .receive("error", resp => {
    console.log("Unable to join", resp);
  });

channel.on("match", payload => {
  let messageItem = document.createElement("li");
  messageItem.innerText = `${JSON.stringify(payload)}`;
  matched.appendChild(messageItem);
});

channel.on("invalid", payload => {
  let messageItem = document.createElement("li");
  messageItem.innerText = `${JSON.stringify(payload)}`;
  invalid.appendChild(messageItem);
});

channel.on("total", payload => {
  total.innerText = payload.total;
});

export default socket;
