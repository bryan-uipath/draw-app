// Pure sticky-note store logic. No I/O — fully testable.
export const createNotesStore = () => ({ notes: [], nextId: 1 });

export const addNote = (store, { text, x, y }) => ({
  notes: [...store.notes, { id: store.nextId, text, x, y }],
  nextId: store.nextId + 1,
});

export const getNotes = (store) => store.notes;
