<template lang="pug">
.thread-comment
  .thread-comment__author
    a.thread-comment__user-link(:href='answer.user.url', itemprop='url')
      img.thread-comment__user-icon.a-user-icon(
        :src='answer.user.avatar_url',
        :title='answer.user.icon_title',
        :class='[roleClass, daimyoClass]'
      )
  .a-card.is-answer(v-if='!editing')
    .answer-badge(v-if='hasCorrectAnswer && answer.type == "CorrectAnswer"')
      .answer-badge__icon
        i.fas.fa-star
      .answer-badge__label ベストアンサー
    .thread-comment__body
      header.thread-comment__body-header
        h2.thread-comment__title
          a.thread-comment__title-link(:href='answer.user.url', itemprop='url')
            | {{ answer.user.login_name }}
        time.thread-comment__created-at(
          :class='{ "is-active": activating }',
          :datetime='answerCreatedAt',
          pubdate='pubdate',
          @click='copyAnswerURLToClipboard(answer.id)'
        )
          | {{ updatedAt }}
      .thread-comment__description.a-long-text.is-md(
        v-html='markdownDescription'
      )
    .thread-comment__reactions
      reaction(
        v-bind:reactionable='answer',
        v-bind:currentUser='currentUser',
        v-bind:questionUser='questionUser',
        v-bind:reactionableId='reactionableId'
      )
    footer.card-footer
      .card-main-actions
        ul.card-main-actions__items
          li.card-main-actions__item(
            v-if='answer.user.id == currentUser.id || isRole("admin")'
          )
            button.card-main-actions__action.a-button.is-md.is-secondary.is-block(
              @click='editAnswer'
            )
              i.fas.fa-pen
              | 内容修正
          li.card-main-actions__item(
            v-if='!hasCorrectAnswer && answer.type != "CorrectAnswer" && (currentUser.id === questionUser.id || isRole("mentor"))'
          )
            button.card-main-actions__action.a-button.is-md.is-primary.is-block(
              @click='makeToBestAnswer'
            )
              | ベストアンサーにする
          li.card-main-actions__item(
            v-if='hasCorrectAnswer && answer.type == "CorrectAnswer" && (currentUser.id === questionUser.id || isRole("mentor"))'
          )
            button.card-main-actions__action.a-button.is-md.is-muted.is-block(
              @click='cancelBestAnswer'
            )
              | ベストアンサーを取り消す
          li.card-main-actions__item.is-sub(
            v-if='answer.user.id == currentUser.id || isRole("mentor")'
          )
            button.card-main-actions__muted-action(@click='deleteAnswer')
              | 削除する
  .a-card.is-answer(v-show='editing')
    .thread-comment-form__form
      .a-form-tabs.js-tabs
        .a-form-tabs__tab.js-tabs__tab(
          v-bind:class='{ "is-active": isActive("answer") }',
          @click='changeActiveTab("answer")'
        )
          | コメント
        .a-form-tabs__tab.js-tabs__tab(
          v-bind:class='{ "is-active": isActive("preview") }',
          @click='changeActiveTab("preview")'
        )
          | プレビュー
      .a-markdown-input.js-markdown-parent
        .a-markdown-input__inner.js-tabs__content(
          v-bind:class='{ "is-active": isActive("answer") }'
        )
          textarea.a-text-input.a-markdown-input__textarea(
            v-model='description',
            :id='`js-comment-${this.answer.id}`',
            :data-preview='`#js-comment-preview-${this.answer.id}`',
            name='answer[description]'
          )
        .a-markdown-input__inner.js-tabs__content(
          v-bind:class='{ "is-active": isActive("preview") }'
        )
          .js-preview.a-long-text.is-md.a-markdown-input__preview(
            :id='`js-comment-preview-${this.answer.id}`'
          )
      .card-footer
        .card-main-actions
          .card-main-actions__items
            .card-main-actions__item
              button.a-button.is-md.is-warning.is-block(
                @click='updateAnswer',
                v-bind:disabled='!validation'
              )
                | 保存する
            .card-main-actions__item
              button.a-button.is-md.is-secondary.is-block(@click='cancel')
                | キャンセル
</template>
<script>
import Reaction from './reaction.vue'
import MarkdownInitializer from './markdown-initializer'
import TextareaInitializer from './textarea-initializer'
import confirmUnload from './confirm-unload'
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
import role from './role'
dayjs.locale(ja)

export default {
  components: {
    reaction: Reaction
  },
  mixins: [confirmUnload, role],
  props: {
    answer: { type: Object, required: true },
    currentUser: { type: Object, required: true },
    hasCorrectAnswer: { type: Boolean, required: true },
    questionUser: { type: Object, required: true }
  },
  data() {
    return {
      description: '',
      editing: false,
      isCopied: false,
      tab: 'answer',
      question: [],
      activating: false
    }
  },
  computed: {
    markdownDescription: function () {
      const markdownInitializer = new MarkdownInitializer()
      return markdownInitializer.render(this.description)
    },
    answerCreatedAt: function () {
      return dayjs(this.answer.question.created_at).format()
    },
    updatedAt: function () {
      return dayjs(this.answer.updated_at).format('YYYY年MM月DD日(dd) HH:mm')
    },
    roleClass: function () {
      return `is-${this.answer.user.primary_role}`
    },
    daimyoClass: function () {
      return { 'is-daimyo': this.answer.user.daimyo }
    },
    validation: function () {
      return this.description.length > 0
    },
    reactionableId: function () {
      return `Answer_${this.answer.id}`
    }
  },
  created: function () {
    this.description = this.answer.description
  },
  mounted: function () {
    TextareaInitializer.initialize(`#js-comment-${this.answer.id}`)

    const answerAnchor = location.hash
    if (answerAnchor) {
      this.$nextTick(() => {
        location.replace(location.href)
      })
    }
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
    cancel: function () {
      this.description = this.answer.description
      this.editing = false
    },
    editAnswer: function () {
      this.editing = true
      this.$nextTick(function () {
        $(`.answer-id-${this.answer.id}`).trigger('input')
      })
    },
    makeToBestAnswer: function () {
      if (window.confirm('本当に宜しいですか？')) {
        this.$emit('makeToBestAnswer', this.answer.id)
      }
    },
    cancelBestAnswer: function () {
      if (window.confirm('本当に宜しいですか？')) {
        this.$emit('cancelBestAnswer', this.answer.id)
      }
    },
    updateAnswer: function () {
      if (this.description.length < 1) {
        return null
      }
      const params = {
        answer: { description: this.description }
      }
      fetch(`/api/answers/${this.answer.id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then(() => {
          this.$emit('update', this.description, this.answer.id)
          this.editing = false
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    deleteAnswer: function () {
      if (window.confirm('削除してよろしいですか？')) {
        this.$emit('delete', this.answer.id)
      }
    },
    copyAnswerURLToClipboard(answerId) {
      const answerURL = location.href.split('#')[0] + '#answer_' + answerId
      const textBox = document.createElement('textarea')
      textBox.setAttribute('type', 'hidden')
      textBox.textContent = answerURL
      document.body.appendChild(textBox)
      textBox.select()
      document.execCommand('copy')
      document.body.removeChild(textBox)
      this.activating = true
      setTimeout(() => {
        this.activating = false
      }, 4000)
    }
  }
}
</script>
