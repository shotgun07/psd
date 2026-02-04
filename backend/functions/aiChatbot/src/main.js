import { OpenAI } from 'openai';
import { Client, Databases } from 'node-appwrite';

export default async ({ req, res, log, error }) => {
  if (req.method !== 'POST') {
    return res.json({ success: false, message: 'Method not allowed' }, 405);
  }

  try {
    const { message, history } = JSON.parse(req.body);
    
    // Initialize OpenAI
    // Note: OPENAI_API_KEY refers to an environment variable you must set in Appwrite Console
    const openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY, 
    });

    const messages = [
        { role: 'system', content: 'You are a helpful assistant for OBLNS (Libyan Delivery Service). Answer questions about tracking, delivery, and services.' },
        ...(history || []),
        { role: 'user', content: message }
    ];

    const completion = await openai.chat.completions.create({
      messages: messages,
      model: 'gpt-3.5-turbo',
    });

    const aiResponse = completion.choices[0].message.content;

    return res.json({
      success: true,
      message: aiResponse,
    });
  } catch (err) {
    error(err.message);
    return res.json({
      success: false,
      message: 'Internal Server Error',
      error: err.message
    }, 500);
  }
};
