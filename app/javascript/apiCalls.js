export function patchTimeSlot(slot, talk, csrfToken) {
  const talkID = talk.slot ? '' : talk.id.toString();

  const data = JSON.stringify({
    time_slot: {
      program_session_id: talkID
    }
  });

  if (slot.update_path) {
    return fetch(slot.update_path, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      credentials: "same-origin",
      body: data
    })
  }
}