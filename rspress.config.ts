import * as path from 'path';
import { defineConfig } from 'rspress/config';
import ghPages from 'rspress-plugin-gh-pages';
import ga from 'rspress-plugin-google-analytics';

export default defineConfig({
  root: path.join(__dirname, 'docs'),
  title: 'AnyCMS',
  description: '通用 CMS 开发框架',
  icon: '/rspress-icon.png',
  logo: {
    light: '/rspress-light-logo.png',
    dark: '/rspress-dark-logo.png',
  },
  themeConfig: {
    socialLinks: [
      { icon: 'github', mode: 'link', content: 'https://github.com/anycms/website' },
    ],
  },
  plugins:[
    ghPages({
      repo: 'git@github.com:anycms/website.git',
      branch: 'gh-pages',
      siteBase:'/'
    }),
    ga({
      id: 'G-Y3YQ0W814W',
    }),
  ]
});
