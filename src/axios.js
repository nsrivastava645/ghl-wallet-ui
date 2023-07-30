import axios from 'axios';

const instance = axios.create({
  baseURL: 'http://34.131.183.126:3000',
});

export default instance;
