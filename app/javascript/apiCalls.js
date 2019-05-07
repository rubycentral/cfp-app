export function patchTimeSlot(slot, talk, csrfToken) {
  const data = JSON.stringify({
    time_slot: {
      program_session_id: talk.id.toString()
    }
  });

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