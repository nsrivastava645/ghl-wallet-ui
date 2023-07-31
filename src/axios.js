import axios from 'axios';

const instance = axios.create({
  baseURL: 'https://api.neeraj.app/',
});

export default instance;
