import globals from 'globals';
import js from '@eslint/js';
import pluginVue from 'eslint-plugin-vue';

export default [
  {
    name: 'app/files-to-lint',
    files: ['**/*.{js,mjs,jsx,vue}'],
  },

  {
    ignores: ['**/dist/**', '**/dist-ssr/**', '**/coverage/**'],
  },

  {
    languageOptions: {
      globals: {
        ...globals.browser,
      },
    },
  },

  js.configs.recommended,
  ...pluginVue.configs['flat/essential'],
  
  {
    name: 'app/custom-rules',
    rules: {
      // compatibility required rules
      'vue/no-deprecated-dollar-listeners-api': 'off',
      // general js rules
      'no-console': ['error', { allow: ['warn', 'error'] }],
      'no-mixed-spaces-and-tabs': 'error',
      'quotes': ['error', 'single', { avoidEscape: true }],
      'no-multi-spaces': 'error',
      'semi': ['error', 'always'],
      // vue rules
      'vue/comment-directive': 0,
      'vue/html-indent': ['error', 2, {
        attribute: 1,
        baseIndent: 1,
        closeBracket: 0,
        alignAttributesVertically: true,
        ignores: [],
      }],
      'vue/first-attribute-linebreak': ['error', {
        singleline: 'ignore',
        multiline: 'below'
      }],
      'vue/max-attributes-per-line': ['error', {
        singleline: 1,
        multiline: 1,
      }],
      // TODO: Want to look more into this one
      // 'vue/singleline-html-element-content-newline': ['error', {
      //   ignoreWhenNoAttributes: true,
      //   ignoreWhenEmpty: true,
      //   ignores: [],
      // }],
      'vue/html-closing-bracket-newline': ['error', {
        singleline: 'never',
        multiline: 'always',
      }],
      'vue/multiline-html-element-content-newline': ['error', {
        ignoreWhenEmpty: true,
        allowEmptyLines: false,
      }],
      'vue/html-quotes': ['error', 'double', { 'avoidEscape': true }],
      'vue/prop-name-casing': 'error',
      'vue/component-name-in-template-casing': ['error', 'PascalCase', {
        ignores: ['/^h-/']
      }],
      'vue/attribute-hyphenation': 'error',
      'vue/prefer-template': 'warn',
      'vue/padding-line-between-blocks': ['error', 'always'],
    },
  },
];
