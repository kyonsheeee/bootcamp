<template lang="pug">
.thread-comments(v-if='loaded === false')
  commentPlaceholder(v-for='num in placeholderCount', :key='num')
.thread-comments-container(v-else)
  h2.thread-comments-container__title 回答・コメント
  .thread-comments
    answer(
      v-for='answer in answers',
      :key='answer.id',
      :answer='answer',
      :currentUser='currentUser',
      :id='"answer_" + answer.id',
      :questionUser='questionUser',
      :hasCorrectAnswer='hasCorrectAnswer',
      @delete='deleteAnswer',
      @makeToBestAnswer='makeToBestAnswer',
      @cancelBestAnswer='cancelBestAnswer',
      @update='updateAnswer'
    )
    .thread-comment-form
      .thread-comment__author
        img.thread-comment__user-icon.a-user-icon(
          :src='currentUser.avatar_url',
          :title='currentUser.icon_title'
        )
      .thread-comment-form__form.a-card
        .a-form-tabs.js-tabs
          .a-form-tabs__tab.js-tabs__tab(
            :class='{ "is-active": isActive("answer") }',
            @click='changeActiveTab("answer")'
          )
            | コメント
          .a-form-tabs__tab.js-tabs__tab(
            :class='{ "is-active": isActive("preview") }',
            @click='changeActiveTab("preview")'
          )
            | プレビュー
        .a-markdown-input.js-markdown-parent
          .a-markdown-input__inner.js-tabs__content(
            :class='{ "is-active": isActive("answer") }'
          )
            textarea#js-new-comment.a-text-input.js-warning-form.a-markdown-input__textarea(
              v-model='description',
              name='answer[description]',
              data-preview='#new-comment-preview',
              @input='editAnswer'
            )
          .a-markdown-input__inner.js-tabs__content(
            :class='{ "is-active": isActive("preview") }'
          )
            #new-comment-preview.a-long-text.is-md.a-markdown-input__preview
        .card-footer
          .card-main-actions
            .card-main-actions__items
              .card-main-actions__item
                button#js-shortcut-post-comment.a-button.is-md.is-warning.is-block(
                  @click='createAnswer',
                  :disabled='!validation || buttonDisabled'
                )
                  | コメントする
</template>
<script>
import Answer from './answer.vue'
import TextareaInitializer from './textarea-initializer'
import CommentPlaceholder from './comment-placeholder'
import confirmUnload from './confirm-unload'
import toast from './toast'

export default {
  components: {
    answer: Answer,
    commentPlaceholder: CommentPlaceholder
  },
  mixins: [toast, confirmUnload],
  props: {
    questionId: { type: String, required: true },
    questionUser: { type: Object, required: true },
    currentUser: { type: Object, required: true }
  },
  data() {
    return {
      answers: [],
      description: '',
      tab: 'answer',
      buttonDisabled: false,
      question: { correctAnswer: null },
      defaultTextareaSize: null,
      loaded: false,
      editing: false,
      placeholderCount: 3
    }
  },
  computed: {
    validation: function () {
      return this.description.length > 0
    },
    hasCorrectAnswer: function () {
      return this.answers.some((answer) => answer.type === 'CorrectAnswer')
    },
    baseUrl: function () {
      return '/api/answers'
    }
  },
  created: function () {
    fetch(`/api/answers.json?question_id=${this.questionId}`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        json.answers.forEach((c) => {
          this.answers.push(c)
        })

        this.updateAnswerCount()
      })
      .catch((error) => {
        console.warn(error)
      })
      .finally(() => {
        this.loaded = true
        this.$nextTick(() => {
          TextareaInitializer.initialize('#js-new-comment')
          this.setDefaultTextareaSize()
        })
      })
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    isActive: function (tab) {
      return this.tab === tab
    },
    changeActiveTab: function (tab) {
      this.tab = tab
    },
    createAnswer: function () {
      if (this.description.length < 1) {
        return null
      }
      this.buttonDisabled = true
      this.editing = false
      const params = {
        answer: { description: this.description },
        question_id: this.questionId
      }
      fetch(this.baseUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.answers.push(json)
          this.description = ''
          this.tab = 'answer'
          this.buttonDisabled = false
          this.resizeTextarea()
          this.updateAnswerCount()
          this.toast('回答を投稿しました！')
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    deleteAnswer: function (id) {
      fetch(`${this.baseUrl}/${id}.json`, {
        method: 'DELETE',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then(() => {
          this.answers.some((answer, i) => {
            if (answer.id !== id) {
              return false
            }

            this.answers.splice(i, 1)

            if (answer.type === 'CorrectAnswer') {
              this.$emit('cancelSolveQuestion')
            }

            return true
          })

          this.updateAnswerCount()
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    updateAnswer(description, id) {
      const updatedAnswer = this.answers.find((answer) => {
        return answer.id === id
      })
      updatedAnswer.description = description
    },
    requestSolveQuestion: function (id, isCancel) {
      const params = {
        question_id: this.questionId
      }

      return fetch(`${this.baseUrl}/${id}/correct_answer`, {
        method: isCancel ? 'PATCH' : 'POST',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
    },
    findAnswerById: function (id) {
      return this.answers.find((answer) => answer.id === id)
    },
    makeToBestAnswer: function (id) {
      this.requestSolveQuestion(id, false)
        .then((response) => {
          return response.json()
        })
        .then((answer) => {
          this.findAnswerById(answer.id).type = 'CorrectAnswer'

          this.$emit('solveQuestion', answer)
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    cancelBestAnswer: function (id) {
      this.requestSolveQuestion(id, true)
        .then(() => {
          this.findAnswerById(id).type = ''

          this.$emit('cancelSolveQuestion')
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    updateAnswerCount: function () {
      this.$emit('updateAnswerCount', this.answers.length)
    },
    setDefaultTextareaSize: function () {
      const textarea = document.getElementById('js-new-comment')
      this.defaultTextareaSize = textarea.scrollHeight
    },
    resizeTextarea: function () {
      const textarea = document.getElementById('js-new-comment')
      textarea.style.height = `${this.defaultTextareaSize}px`
    },
    editAnswer() {
      if (this.description.length > 0) {
        this.editing = true
      }
    }
  }
}
</script>
