function getMeta(metaName) {
  const metas = document.getElementsByTagName("meta");

  for (let i = 0; i < metas.length; i++) {
    if (metas[i].getAttribute("name") === metaName) {
      return metas[i].getAttribute("content");
    }
  }

  return "";
}

export function patchTimeSlot(slot, talk) {
  const data = JSON.stringify({
    time_slot: {
      program_session_id: talk.id.toString()
    }
  });
  const csrfToken = getMeta("csrf-token");

  fetch(slot.update_path, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken
    },
    credentials: 'same-origin',
    body: data
  })
  .then(response => {
    return response.json()
  })
}