export function patchTimeSlot(slot, talk, csrfToken) {
  const talkID = talk === null ? '' : talk.id.toString();

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

export function bulkTimeSlots(path, day, rooms, duration, startTimes, csrfToken) {
  const data = JSON.stringify({
    bulk_time_slot: {
      day,
      rooms,
      start_times: startTimes,
      duration
    }
  })
  
  return fetch(path, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": csrfToken
    },
    credentials: "same-origin",
    body: data
  })
}
