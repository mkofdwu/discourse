import fs from 'fs';

import express from 'express';
import cors from 'cors';

const app = express();
app.use(express.json());
app.use(cors({ origin: '*' }));

const writeStreams = new Map<string, fs.WriteStream>();

function getAppendStream(chatId: string) {
  if (!writeStreams.has(chatId)) {
    // TODO: handle if file does not exist
    writeStreams.set(chatId, fs.createWriteStream(chatId + '.txt', { flags: 'a' }));
  }
  return writeStreams.get(chatId)!;
}

app.get('/chat/:id/log', (req, res) => {
  // returns the str representation of the chat log
  fs.readFile(req.params.id + '.txt', (err, data) => {
    if (err != null) {
      res.status(500).send({ error: err.message });
    }
    res.send(data.toString());
  });
});

app.post('/chat/:id/log', (req, res) => {
  const stream = getAppendStream(req.params.id);
  const { id, senderUsername, text, hasPhoto, sentTimestamp } = req.body;
  const sentOnStr = new Date(sentTimestamp).toLocaleString();
  const line = `${id} ${sentOnStr} ${senderUsername}: ${hasPhoto ? '[PHOTO] ' : ''}${text}\n`;
  stream.write(line);
  res.sendStatus(200);
});

app.get('/chat/:id/search', (req, res) => {
  fs.readFile(req.params.id + '.txt', (err, data) => {
    if (err != null) {
      res.status(500).send({ error: err.message });
    }
    // TODO: find all messageIds containing the text
    // also return all the locations of each message relative to
    // entire chat log (fractions)

    const messageIds: string[] = [];

    const re = new RegExp(`^(\\w+) .*?${req.body.query}.*?$`, 'gm'); // match groups: id,
    const s = data.toString();
    let m;

    do {
      m = re.exec(s);
      if (m) {
        messageIds.push(m[1]);
      }
    } while (m);

    res.send(messageIds);
  });
});

app.listen(8000, () => console.log('server started on port 8000'));
